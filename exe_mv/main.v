module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('mv')
	fp.version('1.0.0')
	fp.description('Rename SOURCE to DEST, or move SOURCE(s) to DIRECTORY.')
	fp.skip_executable()

	force := fp.bool('force', `f`, false, 'do not prompt before overwriting')
	interactive := fp.bool('interactive', `i`, false, 'prompt before overwrite')
	verbose := fp.bool('verbose', `v`, false, 'explain what is being done')
	
	no_clobber := fp.bool('no-clobber', `n`, false, 'do not overwrite an existing file')

	extra := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "mv" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in extra {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "mv" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	if extra.len < 2 {
		eprintln("mv: missing file operand")
		return
	}

	sources := extra[..extra.len-1]
	target := extra[extra.len-1]
	target_is_dir := os.is_dir(target)

	if sources.len > 1 && !target_is_dir {
		eprintln("mv: target '${target}' is not a directory")
		return
	}

	mut exit_code := 0
	for src in sources {
		dest := if target_is_dir { os.join_path(target, os.file_name(src)) } else { target }
		
		if !os.exists(src) {
			eprintln("mv: cannot stat '${src}': No such file or directory")
			exit_code = 1
			continue
		}

		if os.exists(dest) && no_clobber {
			continue
		}

		if os.exists(dest) && !force && interactive {
			print("mv: overwrite '${dest}'? ")
			response := os.get_line().to_lower()
			if !response.starts_with('y') {
				continue
			}
		}

		os.mv(src, dest) or {
			eprintln("mv: cannot move '${src}' to '${dest}': ${err}")
			exit_code = 1
			continue
		}

		if verbose {
			println("'${src}' -> '${dest}'")
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
