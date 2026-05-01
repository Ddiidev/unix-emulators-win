module main

import os
import flag

fn main() {
	mut fp := flag.new_flag_parser(os.args.clone())
	fp.application('sort')
	fp.version('1.0.0')
	fp.description('Write sorted concatenation of all FILE(s) to standard output.')
	fp.skip_executable()

	reverse := fp.bool('reverse', `r`, false, 'reverse the result of comparisons')
	numeric := fp.bool('numeric-sort', `n`, false, 'compare according to string numerical value')
	unique := fp.bool('unique', `u`, false, 'with -c, check for strict ordering; without -c, output only the first of an equal run')

	if fp.string('key', `k`, '', 'sort via a key') != '' ||
	   fp.string('field-separator', `t`, '', 'use SEP instead of non-blank to blank transition') != '' {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "sort" COMMAND DOES NOT YET HAVE THIS ARGUMENT.')
		exit(1)
	}

	files := fp.finalize() or {
		eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "sort" COMMAND DOES NOT YET HAVE THIS ARGUMENT ("${err.msg()}").')
		exit(1)
	}

	for arg in files {
		if arg.starts_with('-') && arg != '-' {
			eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "sort" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
			exit(1)
		}
	}

	mut inputs := files.clone()
	if inputs.len == 0 {
		inputs << '-'
	}

	mut all_lines := []string{}
	mut buf := []u8{len: 4096}

	mut exit_code := 0
	for f_path in inputs {
		if f_path == '-' {
			mut stdin := os.stdin()
			for {
				n := stdin.read_bytes_with_newline(mut buf) or { 0 }
				if n == 0 {
					if stdin.eof() { break }
					continue
				}
				all_lines << buf[..n].bytestr()
			}
		} else {
			lines := os.read_lines(f_path) or { 
				eprintln("sort: cannot read '${f_path}': No such file or directory")
				exit_code = 1
				continue 
			}
			for l in lines { all_lines << l + '\n' }
		}
	}

	all_lines.sort_with_compare(fn [reverse, numeric] (a &string, b &string) int {
		mut cmp := 0
		if numeric {
			an := a.int()
			bn := b.int()
			if an < bn { cmp = -1 }
			else if an > bn { cmp = 1 }
		} else {
			if a < b { cmp = -1 }
			else if a > b { cmp = 1 }
		}
		return if reverse { -cmp } else { cmp }
	})

	mut last := ''
	for i, line in all_lines {
		if unique && i > 0 && line == last {
			continue
		}
		print(line)
		last = line
	}

	if exit_code != 0 {
		exit(exit_code)
	}
}
