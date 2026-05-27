module main

import os
import flag
import time

// preprocess_args rewrites shorthand -N (e.g. -20) into -n N
// so the flag parser can handle it normally.
fn preprocess_args(args []string) []string {
	mut result := []string{cap: args.len + 1}
	for arg in args {
		if arg.len > 1 && arg[0] == `-` && arg[1..].bytes().all(it.is_digit()) {
			result << '-n'
			result << arg[1..]
		} else {
			result << arg
		}
	}
	return result
}

fn main() {
	mut fp := flag.new_flag_parser(preprocess_args(os.args))
	fp.application('tail')
	fp.version('1.2.0')
	fp.description('Output the last part of files.')
	fp.skip_executable()

	mut lines := fp.int('lines', `n`, 10, 'output the last K lines, instead of the last 10')
	follow := fp.bool('follow', `f`, false, 'output appended data as the file grows')
	sleep_int := fp.int('sleep-interval', `s`, 1, 'with -f, sleep for approximately N seconds (default 1.0) between iterations')
	verbose := fp.bool('verbose', `v`, false, 'always output headers giving file names')
	quiet := fp.bool('quiet', `q`, false, 'never output headers giving file names')

	files := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "tail" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in files {
		if arg.starts_with('-') && arg != '-' {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "tail" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	mut inputs := files.clone()
	if inputs.len == 0 {
		inputs << '-'
	}

	mut buf := []u8{len: 4096}

	mut exit_code := 0
	for f_path in inputs {
		show_header := (!quiet && inputs.len > 1) || verbose
		if show_header {
			println('==> ${f_path} <==')
		}
		
		if f_path == '-' {
			mut all_contents := []string{}
			mut stdin := os.stdin()
			for {
				n := stdin.read_bytes_with_newline(mut buf) or { 0 }
				if n == 0 {
					if stdin.eof() { break }
					continue
				}
				all_contents << buf[..n].bytestr()
			}
			start := if all_contents.len > lines { all_contents.len - lines } else { 0 }
			for i in start .. all_contents.len {
				print(all_contents[i])
			}
			continue
		}

		if !os.exists(f_path) {
			eprintln("tail: cannot open '${f_path}' for reading: No such file or directory")
			exit_code = 1
			continue
		}

		// Use seek-from-end approach to avoid loading entire file into memory
		tail_from_end(f_path, lines)

		if follow {
			mut f := os.open(f_path) or { 
				exit_code = 1
				continue 
			}
			f.seek(0, .end) or { }
			for {
				pos := f.tell() or { 0 }
				size := os.file_size(f_path)
				if size > pos {
					for {
						n := f.read_bytes_with_newline(mut buf) or { 0 }
						if n == 0 {
							if f.eof() { break }
							continue
						}
						print(buf[..n].bytestr())
					}
				} else if size < pos {
					println("tail: ${f_path}: file truncated")
					f.seek(0, .end) or { }
				}
				time.sleep(sleep_int * time.second)
			}
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}

// tail_from_end reads only the last N lines of a file by seeking from the end,
// avoiding loading the entire file into memory. Handles files of any size.
fn tail_from_end(path string, n int) {
	mut f := os.open(path) or { return }
	defer { f.close() }

	file_size := os.file_size(path)
	if file_size == 0 {
		return
	}

	// Read in chunks from the end to find the last N newlines
	chunk_size := int(4096)
	mut newlines_found := 0
	mut offset := i64(file_size)
	mut tail_data := []u8{}

	for offset > 0 {
		read_size := if offset < chunk_size { int(offset) } else { chunk_size }
		offset -= read_size
		
		f.seek(offset, .start) or { break }
		mut chunk := []u8{len: read_size}
		bytes_read := f.read(mut chunk) or { 0 }
		if bytes_read == 0 { break }
		
		actual := chunk[..bytes_read].clone()

		// Prepend this chunk to our accumulated data
		mut new_data := []u8{cap: actual.len + tail_data.len}
		new_data << actual
		new_data << tail_data
		tail_data = new_data.clone()

		// Count newlines in the chunk (scanning from right to left)
		for i := actual.len - 1; i >= 0; i-- {
			if actual[i] == `\n` {
				newlines_found++
				// We need n+1 newlines to get n complete lines (the last newline is trailing)
				if newlines_found > n {
					// Find the position in tail_data where the (n+1)th newline from the end is
					mut count := 0
					for j := tail_data.len - 1; j >= 0; j-- {
						if tail_data[j] == `\n` {
							count++
							if count > n {
								// Output from j+1 to end
								print(tail_data[j + 1..].bytestr())
								return
							}
						}
					}
					break
				}
			}
		}
	}

	// If we've read the entire file and found fewer than n newlines, print everything
	print(tail_data.bytestr())
}
