module main

pub struct Options {
pub mut:
	recursive bool // -r, -R
	force     bool // -f
	interactive bool // -i
	verbose   bool // -v
	dir_only  bool // -d
}
