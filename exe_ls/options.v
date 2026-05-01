module main

// Flags and Configuration
pub struct Options {
mut:
	all              bool
	almost_all       bool
	long             bool
	human            bool
	si               bool
	reverse          bool
	sort             string // name, size, time, version, extension, none
	time_type        string // modification (mtime), access (atime), status (ctime), birth/creation
	classify         bool
	slash            bool
	recursive        bool
	one_column       bool
	comma            bool
	horizontal       bool
	vertical         bool
	directories_only bool
	inode            bool
	numeric_ids      bool
	hide_owner       bool
	hide_group       bool
	group_dirs_first bool
	print_size       bool // -s
	color            string // always, auto, never
	width            int
	literal          bool
	quote            bool
	time_style       string // locale, full-iso, long-iso, iso
	escape           bool
}
