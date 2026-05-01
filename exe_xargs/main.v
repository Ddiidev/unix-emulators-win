module main

import os

fn main() {
	mut verbose := false
	mut no_run_if_empty := true
	mut null_separator := false
	mut replace_str := ''
	mut max_args := 0
	
	mut cmd_and_args := []string{}
	mut found_cmd := false
	
	mut i := 1
	for i < os.args.len {
		arg := os.args[i]
		if !found_cmd {
			match arg {
				'-t', '--verbose' { verbose = true }
				'-r', '--no-run-if-empty' { no_run_if_empty = true }
				'-0', '--null' { null_separator = true }
				'-h', '--help' {
					println('Usage: xargs [options] [command [initial-arguments]]')
					println('  -0, --null        Input items are terminated by NUL, not whitespace')
					println('  -I REPLACE        Replace occurrences of REPLACE in args with input item')
					println('  -n MAX            Use at most MAX arguments per command line')
					println('  -t, --verbose     Print commands before executing them')
					println('  -r, --no-run-if-empty  Do not run command if input is empty')
					return
				}
				'-I' {
					if i + 1 < os.args.len {
						replace_str = os.args[i + 1]
						i += 2
						continue
					}
				}
				'-n' {
					if i + 1 < os.args.len {
						max_args = os.args[i + 1].int()
						i += 2
						continue
					}
				}
				else {
					if arg.starts_with('-') {
						eprintln('TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "xargs" COMMAND DOES NOT YET HAVE THIS ARGUMENT "${arg}".')
						exit(1)
					}
					found_cmd = true
					cmd_and_args << arg
				}
			}
		} else {
			cmd_and_args << arg
		}
		i++
	}

	if cmd_and_args.len == 0 {
		cmd_and_args << 'echo'
	}

	mut cmd_name := cmd_and_args[0]
	mut base_args := cmd_and_args[1..].clone()

	// Read from stdin
	mut stdin_bytes := os.get_raw_stdin()
	content := stdin_bytes.bytestr()
	
	// Split into items based on separator
	mut input_args := if null_separator {
		content.split('\0').filter(it.len > 0)
	} else {
		content.fields()
	}
	
	if input_args.len == 0 {
		if no_run_if_empty {
			return
		}
	}

	// -I mode: run command once per input item, replacing placeholder
	if replace_str != '' {
		for item in input_args {
			mut replaced_args := []string{}
			for a in base_args {
				replaced_args << a.replace(replace_str, item)
			}
			run_command(cmd_name, replaced_args, verbose)
		}
		return
	}

	// -n mode: run command with batches of N args
	if max_args > 0 {
		mut batch_start := 0
		for batch_start < input_args.len {
			batch_end := if batch_start + max_args > input_args.len { input_args.len } else { batch_start + max_args }
			mut batch_args := base_args.clone()
			for j in batch_start .. batch_end {
				batch_args << input_args[j]
			}
			run_command(cmd_name, batch_args, verbose)
			batch_start = batch_end
		}
		return
	}

	// Default: run command once with all args
	mut final_args := base_args.clone()
	for a in input_args {
		final_args << a
	}
	run_command(cmd_name, final_args, verbose)
}

fn run_command(cmd_name string, args []string, verbose bool) {
	// Handle quotes for Windows
	mut quoted_args := []string{}
	for a in args {
		if a.contains(' ') || a.contains('"') || a.contains("'") {
			quoted_args << '"' + a.replace('"', '\\"') + '"'
		} else {
			quoted_args << a
		}
	}

	if verbose {
		eprintln('${cmd_name} ${quoted_args.join(' ')}')
	}

	full_cmd := cmd_name + ' ' + quoted_args.join(' ')
	res := os.execute(full_cmd)
	print(res.output)
	
	if res.exit_code != 0 {
		exit(res.exit_code)
	}
}
