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

// split_toplevel_alt splits a regex pattern on top-level '|' characters,
// respecting escape sequences and bracket groups ([], ()).
fn split_toplevel_alt(pattern string) []string {
	mut parts := []string{}
	mut current := []u8{}
	mut depth_paren := 0
	mut in_bracket := false
	mut i := 0
	bytes := pattern.bytes()
	for i < bytes.len {
		c := bytes[i]
		if c == `\\` && i + 1 < bytes.len {
			// escaped character — consume both and skip
			current << c
			current << bytes[i + 1]
			i += 2
			continue
		}
		if !in_bracket {
			if c == `[` {
				in_bracket = true
			} else if c == `(` {
				depth_paren++
			} else if c == `)` && depth_paren > 0 {
				depth_paren--
			} else if c == `|` && depth_paren == 0 {
				parts << current.bytestr()
				current.clear()
				i++
				continue
			}
		} else if c == `]` {
			in_bracket = false
		}
		current << c
		i++
	}
	parts << current.bytestr()
	return parts
}

pub fn new_matcher(pattern string, opts Options) !Matcher {
	literal := is_literal_pattern(pattern) && !opts.word_regexp && !opts.line_regexp
	if opts.fixed_strings || literal {
		return build_fixed_matcher(pattern, opts)
	}

	// V's regex module treats '|' at the token level (not full alternation
	// like PCRE/ERE).  Work around this by splitting on top-level '|' and
	// compiling each alternative as a separate RE.
	alternatives := split_toplevel_alt(pattern)

	mut compiled := []regex.RE{cap: alternatives.len}
	mut pats := []string{cap: alternatives.len}
	for alt in alternatives {
		mut pat := alt
		if opts.word_regexp { pat = '\\b' + pat + '\\b' }
		if opts.line_regexp { pat = '^' + pat + '$' }
		if opts.ignore_case {
			pat = '(?i)' + pat
		}
		mut re := regex.regex_opt(pat) or {
			return error("grep: invalid regular expression: ${err.msg()}")
		}
		compiled << re
		pats << pat
	}

	return Matcher{
		res: compiled
		patterns: pats
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
