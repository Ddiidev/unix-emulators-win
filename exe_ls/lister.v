module main

import os
import time

pub fn list_directory(target string, opts Options, depth int) {
	if depth > 0 || opts.recursive {
		println('\n${target}:')
	}

	mut entries := []string{}
	all_entries := os.ls(target) or {
		eprintln("ls: cannot open directory '${target}': Permission denied")
		return
	}
	
	for e in all_entries {
		if !opts.all && !opts.almost_all && e.starts_with('.') {
			continue
		}
		entries << e
	}

	mut file_data := []FileData{}
	for e in entries {
		fd := get_file_data(os.join_path(target, e), e, opts) or { continue }
		file_data << fd
	}

	if opts.all {
		if fd_dot := get_file_data(target, '.', opts) { file_data << fd_dot }
		parent := os.dir(target)
		if fd_dotdot := get_file_data(parent, '..', opts) { file_data << fd_dotdot }
	}

	// Sorting
	file_data.sort_with_compare(fn [opts] (a &FileData, b &FileData) int {
		if opts.sort == 'none' { return 0 }
		
		if opts.group_dirs_first {
			if a.isdir && !b.isdir { return -1 }
			if !a.isdir && b.isdir { return 1 }
		}

		mut cmp := 0
		match opts.sort {
			'size' { 
				if a.size > b.size { cmp = -1 }
				else if a.size < b.size { cmp = 1 }
			}
			'time' {
				ta := a.get_time(opts.time_type)
				tb := b.get_time(opts.time_type)
				if ta > tb { cmp = -1 }
				else if ta < tb { cmp = 1 }
			}
			'extension' {
				if a.extension < b.extension { cmp = -1 }
				else if a.extension > b.extension { cmp = 1 }
			}
			'version' { cmp = natural_cmp(a.name, b.name) }
			else {
				if a.name < b.name { cmp = -1 }
				else if a.name > b.name { cmp = 1 }
			}
		}
		
		if opts.reverse { return -cmp }
		return cmp
	})

	// Total size for long format
	if opts.long || opts.print_size {
		mut total_blocks := u64(0)
		for fd in file_data { total_blocks += fd.blocks }
		println('total ${total_blocks}')
	}

	// Output Formatting
	if opts.long {
		user := if opts.numeric_ids { '1000' } else { os.loginname() or { 'user' } }
		group := user
		for fd in file_data {
			size_str := format_size(fd.size, opts.human, opts.si)
			time_str := format_unix_time(time.unix(fd.get_time(opts.time_type)).local(), opts.time_style)
			perms := if fd.isdir { 'drwxrwxrwx' } else { '-rwxrwxrwx' }
			name_colored := classify_name(fd, opts)
			
			mut row := []string{}
			if opts.inode { row << '${fd.inode:8}' }
			if opts.print_size { row << '${fd.blocks:4}' }
			row << perms
			row << '${fd.links:2}'
			if !opts.hide_owner { row << '${user}' }
			if !opts.hide_group { row << '${group}' }
			row << '${size_str:8}'
			row << time_str
			row << name_colored
			println(row.join(' '))
		}
	} else {
		mut output_items := []string{}
		for fd in file_data {
			mut item := classify_name(fd, opts)
			if opts.print_size {
				item = '${fd.blocks} ' + item
			}
			output_items << item
		}
		
		if opts.one_column || opts.vertical {
			for itm in output_items { println(itm) }
		} else if opts.comma {
			println(output_items.join(', '))
		} else {
			println(output_items.join('  '))
		}
	}

	// Recursive
	if opts.recursive {
		for fd in file_data {
			if fd.isdir && fd.name != '.' && fd.name != '..' {
				list_directory(os.real_path(os.join_path(target, fd.name)), opts, depth + 1)
			}
		}
	}
}
