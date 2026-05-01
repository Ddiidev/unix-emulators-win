module main

import regex

pub struct Matcher {
mut:
	res          []regex.RE
	patterns     []string
	fixed        bool
	case_ins     bool
	word_reg     bool
	line_reg     bool
	cached_start int = -1
	cached_end   int = -1
	cached_valid bool
}

fn is_literal_pattern(pattern string) bool {
	for c in pattern {
		if c in [`.`, `*`, `+`, `?`, `{`, `}`, `[`, `]`, `(`, `)`, `\\`, `^`, `$`] {
			return false
		}
	}
	return true
}

fn build_fixed_matcher(pattern string, opts Options) Matcher {
	mut processed_patterns := []string{}
	mut ins := opts.ignore_case
	raw_patterns := pattern.split('|')
	for p in raw_patterns {
		processed_patterns << if ins { p.to_lower() } else { p }
	}
	return Matcher{
		patterns: processed_patterns
		fixed: true
		case_ins: ins
	}
}

pub fn new_matcher(pattern string, opts Options) !Matcher {
	// Auto-detect literal patterns: if the input contains no regex meta-characters
	// AND no word/line anchors are requested, treat as fixed-string to avoid the
	// expensive NFA-based regex engine entirely.
	literal := is_literal_pattern(pattern) && !opts.word_regexp && !opts.line_regexp
	if opts.fixed_strings || literal {
		return build_fixed_matcher(pattern, opts)
	}

	mut pat := pattern
	if opts.word_regexp { pat = '\\b' + pat + '\\b' }
	if opts.line_regexp { pat = '^' + pat + '$' }

	mut re := regex.regex_opt(pat) or {
		return error("grep: invalid regular expression: ${err.msg()}")
	}
	if opts.ignore_case {
		re.flag |= regex.f_ci
	}

	return Matcher{
		res: [re]
		patterns: [pat]
		fixed: false
		case_ins: opts.ignore_case
	}
}

pub fn (mut m Matcher) find(text string) (int, int) {
	if m.cached_valid {
		return m.cached_start, m.cached_end
	}

	if m.fixed {
		mut t := text
		if m.case_ins { t = t.to_lower() }

		mut first_idx := -1
		mut last_idx := -1

		for pat in m.patterns {
			idx := t.index(pat) or { -1 }
			if idx != -1 {
				if first_idx == -1 || idx < first_idx {
					first_idx = idx
					last_idx = idx + pat.len
				}
			}
		}
		m.cached_start = first_idx
		m.cached_end = last_idx
		m.cached_valid = true
		return first_idx, last_idx
	}

	mut first_s := -1
	mut first_e := -1

	for mut re in m.res {
		s, e := re.find(text)
		if s != -1 {
			if first_s == -1 || s < first_s {
				first_s = s
				first_e = e
			}
		}
	}

	m.cached_start = first_s
	m.cached_end = first_e
	m.cached_valid = true
	return first_s, first_e
}

pub fn (mut m Matcher) matches(text string) bool {
	m.cached_valid = false

	if m.fixed {
		mut t := text
		if m.case_ins { t = t.to_lower() }
		for pat in m.patterns {
			if t.contains(pat) {
				return true
			}
		}
		return false
	}

	s, _ := m.find(text)
	return s != -1
}
