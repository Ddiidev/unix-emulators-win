module main

import os
import time

pub fn format_size(size u64, human bool, si bool) string {
	if !human && !si {
		return size.str()
	}
	base := if si { f64(1000) } else { f64(1024) }
	units := if si { ['B', 'kB', 'MB', 'GB', 'TB'] } else { ['B', 'K', 'M', 'G', 'T'] }
	
	mut s := f64(size)
	mut unit_idx := 0
	for s >= base && unit_idx < units.len - 1 {
		s /= base
		unit_idx++
	}
	if unit_idx == 0 {
		return '${int(s)}${units[unit_idx]}'
	}
	return '${s:.1f}${units[unit_idx]}'
}

pub fn format_unix_time(t time.Time, style string) string {
	now := time.now()
	match style {
		'full-iso' { return t.format_ss() + ' +0000' }
		'long-iso' { return t.custom_format('YYYY-MM-DD HH:mm') }
		'iso' {
			if now.year != t.year { return t.custom_format('MM-DD  YYYY') }
			return t.custom_format('MM-DD HH:mm')
		}
		else {
			m_short := t.smonth()
			day := t.day
			if now.year != t.year || now.unix() - t.unix() > 15552000 {
				return '${m_short} ${day:2}  ${t.year}'
			}
			return '${m_short} ${day:2} ${t.hour:02}:${t.minute:02}'
		}
	}
}

pub fn get_link_count(path string, is_dir bool) int {
	if !is_dir {
		return 1
	}
	mut count := 0
	entries := os.ls(path) or { return 2 }
	for entry in entries {
		if os.is_dir(os.join_path(path, entry)) {
			count++
		}
	}
	return 2 + count
}

pub fn natural_cmp(a string, b string) int {
	a_bytes := a.bytes()
	b_bytes := b.bytes()
	mut i := 0
	mut j := 0

	for i < a_bytes.len && j < b_bytes.len {
		ca := a_bytes[i]
		cb := b_bytes[j]

		a_is_digit := ca >= `0` && ca <= `9`
		b_is_digit := cb >= `0` && cb <= `9`

		if a_is_digit && b_is_digit {
			// Compare numeric segments as integers
			mut na := i64(0)
			for i < a_bytes.len && a_bytes[i] >= `0` && a_bytes[i] <= `9` {
				na = na * 10 + i64(a_bytes[i] - `0`)
				i++
			}
			mut nb := i64(0)
			for j < b_bytes.len && b_bytes[j] >= `0` && b_bytes[j] <= `9` {
				nb = nb * 10 + i64(b_bytes[j] - `0`)
				j++
			}
			if na < nb { return -1 }
			if na > nb { return 1 }
		} else {
			al := if ca >= `A` && ca <= `Z` { ca + 32 } else { ca }
			bl := if cb >= `A` && cb <= `Z` { cb + 32 } else { cb }
			if al < bl { return -1 }
			if al > bl { return 1 }
			i++
			j++
		}
	}

	if a_bytes.len < b_bytes.len { return -1 }
	if a_bytes.len > b_bytes.len { return 1 }
	return 0
}
