module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('rm')
	fp.version('1.0.0')
	fp.description('Remove (unlink) FILE(s).')
	fp.skip_executable()

	mut opts := Options{}
	opts.recursive = fp.bool('recursive', `r`, false, 'remove directories and their contents recursively')
	_ := fp.bool('Recursive', `R`, false, 'equivalent to -r')
	opts.force = fp.bool('force', `f`, false, 'ignore nonexistent files and arguments, never prompt')
	opts.interactive = fp.bool('interactive', `i`, false, 'prompt before every removal')
	opts.verbose = fp.bool('verbose', `v`, false, 'explain what is being done')
	opts.dir_only = fp.bool('dir', `d`, false, 'remove empty directories')

	files := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "rm" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in files {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "rm" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	if files.len == 0 {
		if !opts.force {
			eprintln("rm: missing operand")
			eprintln("Try 'rm --help' for more information.")
		}
		return
	}

	mut exit_code := 0
	for f_path in files {
		remove_path(f_path, opts) or {
			if !opts.force {
				eprintln(err)
				exit_code = 1
			}
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
