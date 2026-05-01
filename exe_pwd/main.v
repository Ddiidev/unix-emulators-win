module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('pwd')
	fp.version('1.0.0')
	fp.description('Print the name of the current working directory.')
	fp.skip_executable()

	_ := fp.bool('logical', `L`, true, 'use PWD from environment, even if it contains symlinks (default)')
	_ := fp.bool('physical', `P`, false, 'avoid all symlinks')

	extra := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "pwd" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in extra {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "pwd" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	println(os.getwd().replace('\\', '/'))
}
