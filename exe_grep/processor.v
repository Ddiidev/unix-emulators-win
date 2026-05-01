module main

import os
import term

// max_line_bytes: any "line" larger than this almost certainly means
// the file is binary or pathologically minified — skip the file entirely.
const max_line_bytes = 1 * 1024 * 1024 // 1 MB

fn is_binary(buf []u8, n int) bool {
	// Check up to 8 KB (not just 4 KB) for null bytes
	check := if n < 8192 { n } else { 8192 }
	for i in 0 .. check {
		if buf[i] == 0 {
			return true
		}
	}
	return false
}

pub fn grep_file(mut f os.File, filename string, mut matcher Matcher, opts Options) int {
	mut matches_count := 0
	mut line_no := 0

	// Context state — use circular buffer for before-context to avoid O(n) deletes
	mut before_buffer := []string{}
	mut before_start := 0 // start index in circular buffer
	mut before_count := 0 // number of items in circular buffer
	mut after_count := 0
	mut last_printed_line := 0

	// 64 KB buffer reduces syscall count vs 4 KB
	mut buf := []u8{len: 65536}
	mut is_first_read := true
	for {
		n := f.read_bytes_with_newline(mut buf) or { 0 }
		if n == 0 {
			if f.eof() { break }
			continue
		}

		// If read_bytes_with_newline grew the buffer past 1 MB, the "line" is
		// pathologically long — treat the file as binary and abort immediately.
		if buf.len > max_line_bytes {
			return 0
		}

		if is_first_read {
			if is_binary(buf, n) {
				return 0
			}
			is_first_read = false
			if opts.before_context > 0 {
				before_buffer = []string{len: opts.before_context}
			}
		}

		line_no++

		// Trim \r\n in-place on the byte slice — ONE allocation instead of two
		// (avoids: bytestr() → string; trim_right() → new string)
		mut end := n
		for end > 0 && (buf[end - 1] == `\r` || buf[end - 1] == `\n`) {
			end--
		}
		trimmed := buf[..end].bytestr()

		mut is_match := matcher.matches(trimmed)
		if opts.invert_match {
			is_match = !is_match
		}

		if is_match {
			matches_count++

			// -m max-count: stop after N matches
			if opts.max_count > 0 && matches_count > opts.max_count {
				break
			}

			if opts.files_with_match {
				if !opts.quiet {
					println(filename)
				}
				return 1
			}

			if opts.files_without_match || opts.count_only {
				continue
			}

			// -o: only print the matched part
			if opts.only_matching && !opts.invert_match {
				start, end_pos := matcher.find(trimmed)
				if start != -1 {
					mut prefix := ''
					if opts.with_filename {
						prefix += term.magenta(filename) + ':'
					}
					if opts.line_number {
						prefix += term.green(line_no.str()) + ':'
					}
					matched_part := trimmed[start..end_pos]
					if opts.color == 'always' || (opts.color == 'auto' && term.can_show_color_on_stdout()) {
						println('${prefix}${term.bold(term.red(matched_part))}')
					} else {
						println('${prefix}${matched_part}')
					}
				}
				continue
			}

			// Print context group separator if needed
			if (opts.before_context > 0 || opts.after_context > 0) && last_printed_line > 0
				&& line_no > last_printed_line + 1 {
				println('--')
			}

			// 1. Print Before Context from circular buffer
			if opts.before_context > 0 && before_count > 0 {
				for i in 0 .. before_count {
					idx := (before_start + i) % before_buffer.len
					b_no := line_no - before_count + i
					if b_no > last_printed_line {
						print_line(filename, b_no, before_buffer[idx], '-', opts, mut matcher,
							false)
						last_printed_line = b_no
					}
				}
				before_count = 0
				before_start = 0
			}

			// 2. Print Matching Line
			print_line(filename, line_no, trimmed, ':', opts, mut matcher, true)
			last_printed_line = line_no

			// 3. Set After Context
			after_count = opts.after_context
		} else {
			if after_count > 0 {
				print_line(filename, line_no, trimmed, '-', opts, mut matcher, false)
				last_printed_line = line_no
				after_count--
			} else {
				if opts.before_context > 0 {
					write_idx := (before_start + before_count) % before_buffer.len
					before_buffer[write_idx] = trimmed
					if before_count < before_buffer.len {
						before_count++
					} else {
						before_start = (before_start + 1) % before_buffer.len
					}
				}
			}
		}
	}

	// -L: print files with NO matches
	if opts.files_without_match && matches_count == 0 {
		println(filename)
	}

	if opts.count_only {
		if opts.with_filename {
			print('${filename}:')
		}
		println(matches_count)
	}

	return matches_count
}

fn print_line(filename string, line_no int, line string, sep string, opts Options, mut matcher Matcher, is_match bool) {
	mut prefix := ''
	if opts.with_filename {
		prefix += term.magenta(filename) + sep
	}
	if opts.line_number {
		prefix += term.green(line_no.str()) + sep
	}

	mut output_line := line
	if is_match && !opts.invert_match
		&& (opts.color == 'always' || (opts.color == 'auto' && term.can_show_color_on_stdout())) {
		mut start := matcher.cached_start
		mut end := matcher.cached_end
		if !matcher.cached_valid {
			s2, e2 := matcher.find(line)
			start = s2
			end = e2
		}
		if start != -1 {
			output_line = line[..start] + term.bold(term.red(line[start..end])) + line[end..]
		}
	}

	println('${prefix}${output_line}')
}

// grep_recursive uses an iterative BFS queue instead of recursion with os.ls().
//
// The recursive approach keeps every parent directory's []string listing alive
// on the call stack until all children return — on a deep tree that means
// thousands of allocations held simultaneously.
//
// The queue-based approach keeps only ONE directory's listing in memory at a
// time; each listing is freed the moment the inner `for item in items` loop
// finishes and `items` goes out of scope.
pub fn grep_recursive(root string, mut matcher Matcher, opts Options) int {
	mut total := 0
	mut pending := []string{cap: 256}
	pending << root
	mut head := 0

	for head < pending.len {
		current := pending[head]
		head++

		// Compact the queue periodically: once we have processed more than 512
		// directory paths, the front of the slice is dead weight — clone the
		// live tail and reset the head so the GC can reclaim the old backing array.
		if head > 512 {
			pending = pending[head..].clone()
			head = 0
		}

		items := os.ls(current) or { continue }
		for item in items {
			full_path := os.join_path(current, item)
			if os.is_dir(full_path) {
				if !path_is_excluded(full_path, opts.exclude_dirs) {
					pending << full_path
				}
			} else {
				if path_is_excluded(full_path, opts.exclude_files) {
					continue
				}
				if !path_is_included(full_path, opts.include_files) {
					continue
				}
				// Fast extension-based binary skip — no file I/O needed
				if is_binary_extension(full_path) {
					continue
				}
				mut f := os.open(full_path) or { continue }
				total += grep_file(mut f, full_path, mut matcher, opts)
				f.close()
			}
		}
		// `items` goes out of scope here and can be GC'd immediately.
		// In the old recursive version it stayed alive on the stack until
		// ALL nested subdirectories had fully returned.
	}
	return total
}
