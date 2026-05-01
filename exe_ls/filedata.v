module main

import os
import term

pub struct FileData {
	name      string
	path      string
	isdir     bool
	size      u64
	blocks    u64
	mtime     i64
	atime     i64
	ctime     i64
	links     int
	inode     u64
	extension string
	is_exe    bool
}

pub fn (f FileData) get_time(time_type string) i64 {
	return match time_type {
		'access', 'atime', 'use' { f.atime }
		'status', 'status_time', 'ctime' { f.ctime }
		else { f.mtime }
	}
}

pub fn get_file_data(path string, name string, opts Options) ?FileData {
	stat := os.stat(path) or { return none }
	is_dir := os.is_dir(path)
	
	ext := if is_dir { '' } else { os.file_ext(name).trim_left('.') }
	is_exe := !is_dir && (ext.to_lower() in ['exe', 'bat', 'cmd', 'ps1', 'com', 'sh', 'bin'])

	return FileData{
		name: name
		path: path
		isdir: is_dir
		size: stat.size
		blocks: (stat.size + 1023) / 1024
		mtime: stat.mtime
		atime: stat.atime
		ctime: stat.ctime
		links: if opts.long { get_link_count(path, is_dir) } else { 1 }
		inode: 0 
		extension: ext
		is_exe: is_exe
	}
}

pub fn classify_name(fd FileData, opts Options) string {
	mut name := fd.name
	if opts.quote {
		name = '"${name}"'
	} else if opts.escape {
		name = name.replace(' ', '\\ ')
	}
	
	mut display_name := name
	if opts.classify {
		if fd.isdir { display_name += '/' }
		else if fd.is_exe { display_name += '*' }
	} else if opts.slash {
		if fd.isdir { display_name += '/' }
	}
	
	// Colorize
	if opts.color == 'always' || (opts.color == 'auto' && term.can_show_color_on_stdout()) {
		if fd.isdir {
			display_name = term.bold(term.blue(display_name))
		} else if fd.is_exe {
			display_name = term.green(display_name)
		}
	}
	
	return display_name
}
