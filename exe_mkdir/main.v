module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('mkdir')
	fp.version('1.0.0')
	fp.description('Create the DIRECTORY(ies), if they do not already exist.')
	fp.skip_executable()

	parents := fp.bool('parents', `p`, false, 'no error if existing, make parent directories as needed')
	verbose := fp.bool('verbose', `v`, false, 'print a message for each created directory')
	
	// Mode is often not usable on Windows without complex security descriptors, so we stub it.
	if fp.string('mode', `m`, '', 'set file mode (stub on Windows)') != '' {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "mkdir" COMMAND DOES NOT YET HAVE THIS ARGUMENT "-m".')
		exit(1)
	}

	dirs := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "mkdir" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in dirs {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "mkdir" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	if dirs.len == 0 {
		eprintln("mkdir: missing operand")
		return
	}

	mut exit_code := 0
	for d in dirs {
		if os.exists(d) {
			if !parents {
				eprintln("mkdir: cannot create directory '${d}': File exists")
				exit_code = 1
			}
			continue
		}

		if parents {
			os.mkdir_all(d) or {
				eprintln("mkdir: cannot create directory '${d}': ${err}")
				exit_code = 1
				continue
			}
		} else {
			os.mkdir(d) or {
				eprintln("mkdir: cannot create directory '${d}': ${err}")
				exit_code = 1
				continue
			}
		}

		if verbose {
			println("mkdir: created directory '${d}'")
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
