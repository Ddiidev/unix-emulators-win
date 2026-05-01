module main

pub struct Options {
pub mut:
	show_number       bool // -n
	number_nonblank   bool // -b
	squeeze_blank     bool // -s
	show_tabs         bool // -T
	show_ends         bool // -E
	show_nonprinting  bool // -v
}
