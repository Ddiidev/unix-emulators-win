module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('cat')
	fp.version('1.0.0')
	fp.description('Concatenate FILE(s) to standard output.')
	fp.skip_executable()

	mut opts := Options{}
	opts.show_number = fp.bool('number', `n`, false, 'number all output lines')
	opts.number_nonblank = fp.bool('number-nonblank', `b`, false, 'number nonempty output lines, overrides -n')
	opts.squeeze_blank = fp.bool('squeeze-blank', `s`, false, 'suppress repeated empty output lines')
	opts.show_ends = fp.bool('show-ends', `E`, false, 'display $ at end of each line')
	opts.show_tabs = fp.bool('show-tabs', `T`, false, 'display TAB characters as ^I')
	
	if fp.bool('show-all', `A`, false, 'equivalent to -vET') {
		opts.show_ends = true
		opts.show_tabs = true
		// -v is implied but not fully implemented for all chars yet
	}
	
	files := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "cat" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in files {
		if arg.starts_with('-') && arg != '-' {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "cat" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	mut state := State{
		line_count: 0
		last_was_blank: false
	}

	mut inputs := files.clone()
	if inputs.len == 0 {
		inputs << '-'
	}

	for f_path in inputs {
		if f_path == '-' {
			mut stdin := os.stdin()
			process_stream(mut stdin, opts, mut state)
		} else {
			mut f := os.open(f_path) or {
				eprintln("cat: ${f_path}: No such file or directory")
				exit(1)
			}
			process_stream(mut f, opts, mut state)
			f.close()
		}
	}
}
