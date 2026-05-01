module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('cp')
	fp.version('1.0.0')
	fp.description('Copy SOURCE to DEST, or multiple SOURCE(s) to DIRECTORY.')
	fp.skip_executable()

	recursive := fp.bool('recursive', `r`, false, 'copy directories recursively')
	_ := fp.bool('Recursive', `R`, false, 'equivalent to -r')
	force := fp.bool('force', `f`, false, 'if an existing destination file cannot be opened, remove it and try again')
	interactive := fp.bool('interactive', `i`, false, 'prompt before overwrite')
	no_clobber := fp.bool('no-clobber', `n`, false, 'do not overwrite an existing file')
	verbose := fp.bool('verbose', `v`, false, 'explain what is being done')
	
	// Stubs for common cp flags
	if fp.bool('preserve', `p`, false, 'preserve file attributes') ||
	   fp.bool('archive', `a`, false, 'archive mode') {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "cp" COMMAND DOES NOT YET HAVE THIS ARGUMENT.')
		exit(1)
	}

	extra := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "cp" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in extra {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "cp" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	if extra.len < 2 {
		eprintln("cp: missing file operand")
		return
	}

	sources := extra[..extra.len-1]
	target := extra[extra.len-1]
	target_is_dir := os.is_dir(target)

	if sources.len > 1 && !target_is_dir {
		eprintln("cp: target '${target}' is not a directory")
		return
	}

	mut exit_code := 0
	for src in sources {
		dest := if target_is_dir { os.join_path(target, os.file_name(src)) } else { target }
		
		if !os.exists(src) {
			eprintln("cp: cannot stat '${src}': No such file or directory")
			exit_code = 1
			continue
		}

		if os.is_dir(src) && !recursive {
			eprintln("cp: -r not specified; omitting directory '${src}'")
			exit_code = 1
			continue
		}

		if os.exists(dest) && no_clobber {
			continue
		}

		if os.exists(dest) && !force && interactive {
			print("cp: overwrite '${dest}'? ")
			response := os.get_line().to_lower()
			if !response.starts_with('y') {
				continue
			}
		}

		if os.is_dir(src) {
			os.cp_all(src, dest, true) or {
				eprintln("cp: cannot copy directory '${src}' to '${dest}': ${err}")
				exit_code = 1
				continue
			}
		} else {
			os.cp(src, dest) or {
				eprintln("cp: cannot copy '${src}' to '${dest}': ${err}")
				exit_code = 1
				continue
			}
		}

		if verbose {
			println("'${src}' -> '${dest}'")
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
