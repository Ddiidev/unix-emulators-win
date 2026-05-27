module main

import os
import flag

// preprocess_args rewrites shorthand -N (e.g. -30) into -n N
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
	fp.application('head')
	fp.version('1.2.0')
	fp.description('Output the first part of files.')
	fp.skip_executable()

	mut lines := fp.int('lines', `n`, 10, 'print the first K lines instead of the first 10')
	bytes := fp.int('bytes', `c`, 0, 'print the first K bytes')
	verbose := fp.bool('verbose', `v`, false, 'always print headers giving file names')
	quiet := fp.bool('quiet', `q`, false, 'never print headers giving file names')

	files := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "head" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in files {
		if arg.starts_with('-') && arg != '-' {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "head" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
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
		
		mut f := if f_path == '-' { os.stdin() } else { os.open(f_path) or { 
			eprintln("head: cannot open '${f_path}' for reading: No such file or directory")
			exit_code = 1
			continue 
		} }
		
		if bytes > 0 {
			buf_bytes := f.read_bytes(bytes)
			print(buf_bytes.bytestr())
		} else {
			for _ in 0 .. lines {
				n := f.read_bytes_with_newline(mut buf) or { 0 }
				if n == 0 {
					if f.eof() { break }
					continue
				}
				print(buf[..n].bytestr())
			}
		}
		
		if f_path != '-' {
			f.close()
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
