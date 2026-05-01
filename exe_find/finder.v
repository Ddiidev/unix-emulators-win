module main

import os

struct CompiledFilter {
mut:
	filter   Filter
	name_re  ?CompiledGlob
	iname_re ?CompiledGlob
}

struct CompiledGlob {
	raw  string
	case_ins bool
	is_regex  bool
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

fn compile_glob(pattern_str string, case_ins bool) ?CompiledGlob {
	mut raw := pattern_str
	if case_ins {
		raw = pattern_str.to_lower()
	}
	is_lit := !raw.contains('*') && !raw.contains('?')
	return CompiledGlob{
		raw: raw
		case_ins: case_ins
		is_regex: !is_lit
	}
}

fn match_glob(name string, cg ?CompiledGlob) bool {
	cg2 := cg or { return true }
	if !cg2.is_regex {
		target := if cg2.case_ins { name.to_lower() } else { name }
		return target == cg2.raw
	}
	return match_glob_pattern(name, cg2)
}

fn match_glob_pattern(name string, cg CompiledGlob) bool {
	target := if cg.case_ins { name.to_lower() } else { name }
	pattern := cg.raw
	return glob_match(target, pattern, 0, 0)
}

fn glob_match(s string, p string, si int, pi int) bool {
	mut s_idx := si
	mut p_idx := pi

	for p_idx < p.len {
		if p[p_idx] == `*` {
			for p_idx < p.len && p[p_idx] == `*` {
				p_idx++
			}
			if p_idx == p.len {
				return true
			}
			for s_idx < s.len {
				if glob_match(s, p, s_idx, p_idx) {
					return true
				}
				s_idx++
			}
			return false
		}
		if s_idx >= s.len {
			return false
		}
		if p[p_idx] == `?` || s[s_idx] == p[p_idx] {
			s_idx++
			p_idx++
			continue
		}
		return false
	}
	return s_idx == s.len
}

fn matches_filter_compiled(item string, full_path string, cf CompiledFilter) bool {
	if cf.filter.name != '' && !match_glob(item, cf.name_re) {
		return false
	}
	if cf.filter.iname != '' && !match_glob(item, cf.iname_re) {
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
