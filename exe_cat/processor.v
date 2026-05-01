module main

import os

pub struct State {
pub mut:
	line_count     int
	last_was_blank bool
}

pub fn process_stream(mut f os.File, opts Options, mut state State) {
	mut buf := []u8{len: 4096}
	for {
		n := f.read_bytes_with_newline(mut buf) or { 0 }
		if n == 0 {
			if f.eof() { break }
			continue
		}
		
		// Convert to string and handle the newline behavior
		mut line := buf[..n].bytestr()
		
		// Standard cat usually includes the newline in the line
		// We need to check if it's blank EXCLUDING the newline for -s and -b
		trimmed := line.trim_right('\r\n')
		is_blank := trimmed.len == 0
		
		// Squeeze blank
		if opts.squeeze_blank && is_blank && state.last_was_blank {
			continue
		}
		
		mut output := trimmed
		
		// Transformations
		if opts.show_tabs {
			output = output.replace('\t', '^I')
		}
		
		// Numbering
		if opts.number_nonblank {
			if !is_blank {
				state.line_count++
				print('${state.line_count:6}\t')
			}
		} else if opts.show_number {
			state.line_count++
			print('${state.line_count:6}\t')
		}
		
		// Print line + optional end $
		if opts.show_ends {
			print(output)
			println('$')
		} else {
			println(output)
		}
		
		state.last_was_blank = is_blank
	}
}
