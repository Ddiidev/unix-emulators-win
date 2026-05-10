module main

import os
import flag

fn main() {
	raw_args := os.args.clone()
	filtered_args, exclude_files, exclude_dirs, include_files := split_custom_flags(raw_args)

	mut fp := flag.new_flag_parser(filtered_args)
	fp.application('grep')
	fp.version('1.2.0')
	fp.description('Search for PATTERN in each FILE or standard input.')
	fp.skip_executable()

	mut opts := Options{
		color: 'auto'
	}
	
	opts.ignore_case = fp.bool('ignore-case', `i`, false, 'ignore case distinctions')
	opts.invert_match = fp.bool('invert-match', `v`, false, 'select non-matching lines')
	opts.line_number = fp.bool('line-number', `n`, false, 'print line number with output lines')
	opts.count_only = fp.bool('count', `c`, false, 'print only a count of matching lines per file')
	opts.files_with_match = fp.bool('files-with-matches', `l`, false, 'print only names of FILEs with selected lines')
	opts.files_without_match = fp.bool('files-without-matches', `L`, false, 'print only names of FILEs with no selected lines')
	opts.recursive = fp.bool('recursive', `r`, false, 'like --recursive')
	if fp.bool('Recursive', `R`, false, 'equivalent to --recursive') {
		opts.recursive = true
	}
	
	opts.word_regexp = fp.bool('word-regexp', `w`, false, 'force PATTERN to match only whole words')
	opts.line_regexp = fp.bool('line-regexp', `x`, false, 'force PATTERN to match only whole lines')
	opts.fixed_strings = fp.bool('fixed-strings', `F`, false, 'interpret PATTERN as a fixed string')
	// -E / -G: accepted for GNU grep compatibility (no-op — we already use ERE semantics)
	fp.bool('extended-regexp', `E`, false, 'interpret PATTERN as an extended regular expression (default)')
	fp.bool('basic-regexp', `G`, false, 'interpret PATTERN as a basic regular expression')
	opts.only_matching = fp.bool('only-matching', `o`, false, 'show only the matching part of lines')
	
	opts.no_filename = fp.bool('no-filename', `h`, false, 'suppress the file name prefix on output')
	opts.with_filename = fp.bool('with-filename', `H`, false, 'print the file name prefix on output')

	opts.after_context = fp.int('after-context', `A`, 0, 'print NUM lines of trailing context')
	opts.before_context = fp.int('before-context', `B`, 0, 'print NUM lines of leading context')
	ctx := fp.int('context', `C`, 0, 'print NUM lines of output context')
	if ctx > 0 {
		opts.after_context = ctx
		opts.before_context = ctx
	}
	opts.max_count = fp.int('max-count', `m`, 0, 'stop after NUM matches per file')

	opts.color = fp.string('color', 0, 'auto', 'use markers to highlight the matching strings')
	opts.quiet = fp.bool('quiet', `q`, false, 'do not write anything to standard output')
	opts.silent = fp.bool('silent', `s`, false, 'suppress error messages about nonexistent or unreadable files')
	opts.exclude_files = exclude_files
	opts.exclude_dirs = exclude_dirs
	if opts.exclude_dirs.len == 0 && opts.recursive {
		opts.exclude_dirs = default_exclude_dirs.clone()
	}
	opts.include_files = include_files

	extra := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "grep" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in extra {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "grep" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	if extra.len == 0 {
		if !opts.quiet {
			eprintln("Usage: grep [OPTION]... PATTERN [FILE]...")
		}
		exit(1)
	}

	mut raw_pattern := extra[0]
	// Normalization: common in Unix grep to use \| for OR in basic regex, 
	// but ERE uses |. We support both by converting \| to |.
	mut pattern := raw_pattern.replace('\\|', '|')
	
	mut files := extra[1..].clone()

	mut matcher := new_matcher(pattern, opts) or {
		if !opts.silent && !opts.quiet {
			eprintln(err)
		}
		exit(1)
	}

	mut total_matches := 0
	mut had_error := false

	if files.len == 0 {
		if opts.recursive {
			total_matches += grep_recursive('.', mut matcher, opts)
		} else {
			mut stdin := os.stdin()
			total_matches += grep_file(mut stdin, '(standard input)', mut matcher, opts)
		}
	} else {
		if files.len > 1 && !opts.no_filename {
			opts.with_filename = true
		}
		if opts.recursive {
			opts.with_filename = true
		}

		for f_path in files {
			if path_is_excluded(f_path, opts.exclude_files) || path_is_excluded(f_path, opts.exclude_dirs) {
				continue
			}

			if os.is_dir(f_path) {
				if opts.recursive {
					total_matches += grep_recursive(f_path, mut matcher, opts)
				} else {
					if !opts.silent && !opts.quiet {
						eprintln("grep: ${f_path}: Is a directory")
					}
					had_error = true
				}
				continue
			}
			
			if !os.exists(f_path) {
				if !opts.silent && !opts.quiet {
					eprintln("grep: ${f_path}: No such file or directory")
				}
				had_error = true
				continue
			}
			
			mut f := os.open(f_path) or {
				if !opts.silent && !opts.quiet {
					eprintln("grep: ${f_path}: Permission denied")
				}
				had_error = true
				continue
			}
			total_matches += grep_file(mut f, f_path, mut matcher, opts)
			f.close()
		}
	}

	if had_error {
		exit(2)
	}
	if total_matches > 0 {
		exit(0)
	} else {
		exit(1)
	}
}
