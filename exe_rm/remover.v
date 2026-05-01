module main

import os

pub fn remove_path(path string, opts Options) ! {
	if !os.exists(path) {
		if opts.force {
			return
		}
		return error("rm: cannot remove '${path}': No such file or directory")
	}

	is_dir := os.is_dir(path)
	
	if is_dir {
		if !opts.recursive && !opts.dir_only {
			return error("rm: cannot remove '${path}': Is a directory")
		}
		
		if opts.dir_only && !opts.recursive {
			// Check if empty
			entries := os.ls(path) or { []string{} }
			if entries.len > 0 {
				return error("rm: cannot remove '${path}': Directory not empty")
			}
		}
	}

	// Interactive prompt
	if opts.interactive {
		prompt := if is_dir { "rm: remove directory '${path}'? " } else { "rm: remove file '${path}'? " }
		print(prompt)
		response := os.get_line().to_lower()
		if !response.starts_with('y') {
			return
		}
	}

	// Removal logic
	if is_dir && opts.recursive {
		if opts.interactive {
			// Walk and prompt for each item
			items := os.ls(path) or { []string{} }
			for item in items {
				full_path := os.join_path(path, item)
				remove_path(full_path, opts) or {
					eprintln(err)
				}
			}
			// Finally remove the dir itself
			os.rmdir(path) or { return err }
		} else {
			os.rmdir_all(path) or { return err }
		}
	} else if is_dir {
		os.rmdir(path) or { return err }
	} else {
		os.rm(path) or { return err }
	}

	if opts.verbose {
		println("removed '${path}'")
	}
}
