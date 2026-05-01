module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('uniq')
	fp.version('1.1.0')
	fp.description('Filter adjacent matching lines from INPUT (or standard input), writing to OUTPUT (or standard output).')
	fp.skip_executable()

	count := fp.bool('count', `c`, false, 'prefix lines by the number of occurrences')
	repeated := fp.bool('repeated', `d`, false, 'only print duplicate lines, one for each group')
	unique := fp.bool('unique', `u`, false, 'only print unique lines')
	ignore_case := fp.bool('ignore-case', `i`, false, 'ignore differences in case when comparing')

	files := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "uniq" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in files {
		if arg.starts_with('-') && arg != '-' {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "uniq" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	mut input_path := if files.len > 0 { files[0] } else { '-' }
	
	mut f := if input_path == '-' { os.stdin() } else { 
		os.open(input_path) or { 
			eprintln("uniq: ${input_path}: No such file or directory")
			exit(1)
		} 
	}
	
	mut last_line := ''
	mut current_count := 0
	mut first := true
	mut buf := []u8{len: 4096}

	for {
		n := f.read_bytes_with_newline(mut buf) or { 0 }
		if n == 0 {
			if f.eof() {
				if !first {
					print_uniq(last_line, current_count, count, repeated, unique)
				}
				break
			}
			continue
		}
		
		line := buf[..n].bytestr()
		
		if first {
			last_line = line
			current_count = 1
			first = false
			continue
		}
		
		// Compare: trim newlines, optionally case-insensitive
		a := line.trim_right('\r\n')
		b := last_line.trim_right('\r\n')
		lines_equal := if ignore_case { a.to_lower() == b.to_lower() } else { a == b }

		if lines_equal {
			current_count++
		} else {
			print_uniq(last_line, current_count, count, repeated, unique)
			last_line = line
			current_count = 1
		}
	}
	
	if input_path != '-' {
		f.close()
	}
}

fn print_uniq(line string, n int, show_count bool, repeated bool, unique bool) {
	if repeated && n == 1 { return }
	if unique && n > 1 { return }
	
	if show_count {
		print('${n:7} ')
	}
	print(line)
}
