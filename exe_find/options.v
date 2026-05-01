module main

pub struct Filter {
pub mut:
	name  string
	iname string
	typ   string
	empty bool
}

pub struct Options {
pub mut:
	filters   []Filter
	delete    bool
	max_depth int
}
