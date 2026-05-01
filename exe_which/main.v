module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('which')
	fp.version('1.0.0')
	fp.description('Locate a command.')
	fp.skip_executable()

	all := fp.bool('all', `a`, false, 'print all matching pathnames of each argument')

	commands := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "which" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in commands {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "which" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	if commands.len == 0 {
		return
	}

	path := os.getenv('PATH')
	path_sep := if os.user_os() == 'windows' { ';' } else { ':' }
	dirs := path.split(path_sep)
	
	extensions := if os.user_os() == 'windows' {
		exts := os.getenv('PATHEXT').split(';')
		if exts.len > 0 { exts } else { ['.exe', '.bat', '.cmd', '.com'] }
	} else {
		['']
	}

	mut exit_code := 0
	for cmd in commands {
		mut found := false
		
		if cmd.contains('/') || cmd.contains('\\') {
			if os.exists(cmd) {
				println(os.real_path(cmd).replace('\\', '/'))
				found = true
			}
		} else {
			for dir in dirs {
				for ext in extensions {
					full_path := os.join_path(dir, cmd + ext.to_lower())
					if os.exists(full_path) && !os.is_dir(full_path) {
						println(os.real_path(full_path).replace('\\', '/'))
						found = true
						if !all { break }
					}
				}
				if found && !all { break }
			}
		}
		
		if !found {
			exit_code = 1
		}
	}
	
	if exit_code != 0 {
		exit(exit_code)
	}
}
