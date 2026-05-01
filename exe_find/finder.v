module main

import os
import regex

struct CompiledFilter {
mut:
	filter   Filter
	name_re  ?regex.RE
	iname_re ?regex.RE
}

fn compile_filters(filters []Filter) []CompiledFilter {
	mut result := []CompiledFilter{cap: filters.len}
	for f in filters {
		mut cf := CompiledFilter{
			filter: f
		}
		if f.name != '' {
			cf.name_re = compile_glob(f.name, false)
		}
		if f.iname != '' {
			cf.iname_re = compile_glob(f.iname, true)
		}
		result << cf
	}
	return result
}

fn compile_glob(pattern_str string, case_ins bool) ?regex.RE {
	mut p := pattern_str.replace('.', '\\.').replace('*', '.*').replace('?', '.')
	if !p.starts_with('^') {
		p = '^' + p
	}
	if !p.ends_with('$') {
		p = p + '$'
	}
	mut re := regex.regex_opt(p) or { return none }
	if case_ins {
		re.flag |= regex.f_ci
	}
	return re
}

fn match_name_compiled(name string, re_opt ?regex.RE) bool {
	mut re := re_opt or { return true }
	return re.matches_string(name)
}

fn matches_filter_compiled(item string, full_path string, cf CompiledFilter) bool {
	if cf.filter.name != '' && !match_name_compiled(item, cf.name_re) {
		return false
	}
	if cf.filter.iname != '' && !match_name_compiled(item, cf.iname_re) {
		return false
	}
	if cf.filter.typ != '' {
		if cf.filter.typ == 'f' && os.is_dir(full_path) {
			return false
		} else if cf.filter.typ == 'd' && !os.is_dir(full_path) {
			return false
		}
	}
	if cf.filter.empty {
		if os.is_dir(full_path) {
			entries := os.ls(full_path) or { []string{} }
			if entries.len > 0 {
				return false
			}
		} else {
			size := os.file_size(full_path)
			if size > 0 {
				return false
			}
		}
	}
	return true
}

pub fn walk_dir(path string, opts Options, compiled []CompiledFilter, depth int) {
	if depth >= opts.max_depth {
		return
	}

	items := os.ls(path) or { return }
	for item in items {
		full_path := os.join_path(path, item)

		mut matches_any := false
		for cf in compiled {
			f := cf.filter
			if f.name == '' && f.iname == '' && f.typ == '' && !f.empty && compiled.len > 1 {
				continue
			}
			if matches_filter_compiled(item, full_path, cf) {
				matches_any = true
				break
			}
		}

		if matches_any {
			if opts.delete {
				if os.is_dir(full_path) {
					os.rmdir_all(full_path) or {
						eprintln("find: cannot delete ${full_path}: ${err}")
					}
				} else {
					os.rm(full_path) or {
						eprintln("find: cannot delete ${full_path}: ${err}")
					}
				}
			} else {
				println(full_path.replace('\\', '/'))
			}
		}

		if os.is_dir(full_path) {
			if !opts.delete || !matches_any {
				walk_dir(full_path, opts, compiled, depth + 1)
			}
		}
	}
}
