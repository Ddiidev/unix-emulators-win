module main

import os
import flag
import time

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('touch')
	fp.version('1.1.0')
	fp.description('Update the access and modification times of each FILE to the current time.')
	fp.skip_executable()

	no_create := fp.bool('no-create', `c`, false, 'do not create any files')
	access_only := fp.bool('access', `a`, false, 'change only the access time')
	mod_only := fp.bool('modification', `m`, false, 'change only the modification time')

	files := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "touch" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in files {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "touch" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	if files.len == 0 {
		eprintln("touch: missing file operand")
		return
	}

	mut exit_code := 0
	for f in files {
		if os.exists(f) {
			now := int(time.now().unix())
			stat := os.stat(f) or {
				eprintln("touch: cannot touch '${f}': ${err}")
				exit_code = 1
				continue
			}
			
			atime := if mod_only && !access_only { int(stat.atime) } else { now }
			mtime := if access_only && !mod_only { int(stat.mtime) } else { now }
			
			os.utime(f, atime, mtime) or {
				eprintln("touch: cannot touch '${f}': ${err}")
				exit_code = 1
				continue
			}
		} else {
			if !no_create {
				os.create(f) or {
					eprintln("touch: cannot create '${f}': ${err}")
					exit_code = 1
					continue
				}
			}
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
