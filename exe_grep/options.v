module main

pub struct Options {
pub mut:
	ignore_case         bool // -i
	invert_match        bool // -v
	line_number         bool // -n
	count_only          bool // -c
	files_with_match    bool // -l
	files_without_match bool // -L
	recursive           bool // -r, -R
	word_regexp         bool // -w
	line_regexp         bool // -x
	fixed_strings       bool // -F
	only_matching       bool // -o
	color               string // always, auto, never
	no_filename         bool // -h
	with_filename       bool // -H
	after_context       int  // -A
	before_context      int  // -B
	max_count           int  // -m
	quiet               bool // -q
	silent              bool // -s
	exclude_files       []string
	exclude_dirs        []string
	include_files       []string
}
