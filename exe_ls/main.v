module main

import os
import flag
import time

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('ls')
	fp.version('1.1.1')
	fp.description('List information about the FILEs (the current directory by default).')
	fp.skip_executable()

	mut opts := Options{
		width: 80
		color: 'auto'
		sort: 'name'
		time_type: 'modification'
		time_style: 'locale'
	}

	opts.all = fp.bool('all', `a`, false, 'do not ignore entries starting with .')
	opts.almost_all = fp.bool('almost-all', `A`, false, 'do not list implied . and ..')
	opts.long = fp.bool('long', `l`, false, 'use a long listing format')
	opts.human = fp.bool('human-readable', `h`, false, 'with -l, print sizes like 1K 234M 2G etc.')
	opts.si = fp.bool('si', 0, false, 'likewise, but use powers of 1000 not 1024')
	opts.reverse = fp.bool('reverse', `r`, false, 'reverse order while sorting')
	opts.recursive = fp.bool('recursive', `R`, false, 'list subdirectories recursively')
	opts.one_column = fp.bool('one-line', `1`, false, 'list one file per line')
	opts.comma = fp.bool('commas', `m`, false, 'fill width with a comma separated list of entries')
	opts.horizontal = fp.bool('horizontal', `x`, false, 'list entries by lines instead of by columns')
	opts.vertical = fp.bool('vertical', `C`, false, 'list entries by columns')
	opts.classify = fp.bool('classify', `F`, false, 'append indicator (one of */=>@|) to entries')
	opts.slash = fp.bool('slash', `p`, false, 'append / indicator to directories')
	opts.group_dirs_first = fp.bool('group-directories-first', 0, false, 'group directories before files')
	opts.inode = fp.bool('inode', `i`, false, 'print the index number of each file')
	opts.print_size = fp.bool('size', `s`, false, 'print the allocated size of each file, in blocks')
	opts.numeric_ids = fp.bool('numeric-uid-gid', `n`, false, 'like -l, but list numeric user and group IDs')
	opts.hide_owner = fp.bool('no-owner', `g`, false, 'like -l, but do not list owner')
	opts.hide_group = fp.bool('no-group', `G`, false, 'in a long listing, don\'t print group names')
	opts.directories_only = fp.bool('directory', `d`, false, 'list directories themselves, not their contents')
	opts.quote = fp.bool('quote-name', `Q`, false, 'enclose entry names in double quotes')
	opts.escape = fp.bool('escape', `b`, false, 'print C-style escapes for nongraphic characters')

	if fp.bool('sort-size', `S`, false, 'sort by file size, largest first') { opts.sort = 'size' }
	if fp.bool('time', `t`, false, 'sort by time, newest first') { opts.sort = 'time' }
	if fp.bool('version', `v`, false, 'natural sort of (version) numbers within text') { opts.sort = 'version' }
	if fp.bool('extension', `X`, false, 'sort alphabetically by entry extension') { opts.sort = 'extension' }
	if fp.bool('no-sort', `U`, false, 'do not sort; list entries in directory order') { opts.sort = 'none' }

	// Time options
	time_val := fp.string('time', 0, 'modification', 'show/sort by time: access, status, modification')
	opts.time_type = time_val
	if fp.bool('access', `u`, false, 'with -lt: sort by, and show, access time') { 
		opts.time_type = 'access'
		opts.sort = if opts.sort == 'name' { 'name' } else { 'time' }
	}
	if fp.bool('status', `c`, false, 'with -lt: sort by, and show, status time') { 
		opts.time_type = 'status'
		opts.sort = if opts.sort == 'name' { 'name' } else { 'time' }
	}

	opts.time_style = fp.string('time-style', 0, 'locale', 'time/date format: full-iso, long-iso, iso, locale')
	if fp.bool('full-time', 0, false, 'like -l --time-style=full-iso') {
		opts.long = true
		opts.time_style = 'full-iso'
	}

	// Alias for -o, -g (owner/group hiding)
	if fp.bool('no-group-long', `o`, false, 'like -l, but do not list group information') {
		opts.long = true
		opts.hide_group = true
	}

	opts.color = fp.string('color', 0, 'auto', 'colorize the output (always, auto, never)')

	args := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "ls" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in args {
		if arg.starts_with('-') {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "ls" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	mut targets := args.clone()
	if targets.len == 0 {
		targets << '.'
	}

	mut exit_code := 0
	for target in targets {
		if opts.directories_only {
			if fd := get_file_data(target, target, opts) {
				if opts.long {
					user := os.loginname() or { 'user' }
					size_str := format_size(fd.size, opts.human, opts.si)
					time_str := format_unix_time(time.unix(fd.mtime).local(), opts.time_style)
					println('drwxrwxrwx  1 ${user} ${user} ${size_str:8} ${time_str} ${classify_name(fd, opts)}')
				} else {
					println(classify_name(fd, opts))
				}
			} else {
				exit_code = 1
			}
			continue
		}

		if os.is_dir(target) {
			list_directory(target, opts, 0)
		} else if os.exists(target) {
			if fd := get_file_data(target, target, opts) {
				if opts.long {
					user := os.loginname() or { 'user' }
					size_str := format_size(fd.size, opts.human, opts.si)
					time_str := format_unix_time(time.unix(fd.mtime).local(), opts.time_style)
					println('-rwxrwxrwx  1 ${user} ${user} ${size_str:8} ${time_str} ${classify_name(fd, opts)}')
				} else {
					println(classify_name(fd, opts))
				}
			} else {
				exit_code = 1
			}
		} else {
			eprintln("ls: cannot access '${target}': No such file or directory")
			exit_code = 1
		}
	}
	if exit_code != 0 {
		exit(exit_code)
	}
}
