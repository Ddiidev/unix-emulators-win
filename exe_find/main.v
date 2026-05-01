module main

import os

fn main() {
	mut args := os.args[1..].clone()
	mut paths := []string{}
	mut opts := Options{
		max_depth: 9999
	}
	
	// Start with one default filter
	opts.filters << Filter{}
	
	mut i := 0
	for i < args.len {
		arg := args[i]
		mut current_filter := &opts.filters[opts.filters.len - 1]
		
		match arg {
			'-o', '-or' {
				opts.filters << Filter{}
			}
			'-maxdepth' {
				if i + 1 < args.len {
					opts.max_depth = args[i+1].int()
					i++
				}
			}
			'-name' {
				if i + 1 < args.len {
					current_filter.name = args[i+1]
					i++
				}
			}
			'-iname' {
				if i + 1 < args.len {
					current_filter.iname = args[i+1]
					i++
				}
			}
			'-type' {
				if i + 1 < args.len {
					current_filter.typ = args[i+1]
					i++
				}
			}
			'-empty' {
				current_filter.empty = true
			}
			'-delete' {
				opts.delete = true
			}
			'-mtime', '-size', '-exec' {
				eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "find" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
				exit(1)
			}
			else {
				if arg.starts_with('-') {
					eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "find" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
					exit(1)
				} else {
					paths << arg
				}
			}
		}
		i++
	}

	mut search_paths := paths.clone()
	if search_paths.len == 0 {
		search_paths << '.'
	}

	// Pre-compile all regex patterns once
	compiled := compile_filters(opts.filters)

	mut exit_code := 0
	for p in search_paths {
		if !os.exists(p) {
			eprintln("find: '${p}': No such file or directory")
			exit_code = 1
			continue
		}
		
		mut has_active_filters := false
		for f in opts.filters {
			if f.name != '' || f.iname != '' || f.typ != '' || f.empty {
				has_active_filters = true
				break
			}
		}

		if !has_active_filters {
			println(p.replace('\\', '/'))
		}
		walk_dir(p, opts, compiled, 0)
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
