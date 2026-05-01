module main

import os

fn split_custom_flags(args []string) ([]string, []string, []string, []string) {
	mut filtered := []string{cap: args.len}
	mut exclude_files := []string{}
	mut exclude_dirs := []string{}
	mut include_files := []string{}

	if args.len > 0 {
		filtered << args[0]
	}

	mut i := 1
	for i < args.len {
		arg := args[i]

		if arg.starts_with('--exclude-dir=') {
			value := arg['--exclude-dir='.len..]
			if value.len > 0 {
				exclude_dirs << value
			}
			i++
			continue
		}
		if arg == '--exclude-dir' {
			if i + 1 >= args.len {
				eprintln('grep: option --exclude-dir requires an argument')
				exit(1)
			}
			exclude_dirs << args[i + 1]
			i += 2
			continue
		}

		if arg.starts_with('--exclude=') {
			value := arg['--exclude='.len..]
			if value.len > 0 {
				exclude_files << value
			}
			i++
			continue
		}
		if arg == '--exclude' {
			if i + 1 >= args.len {
				eprintln('grep: option --exclude requires an argument')
				exit(1)
			}
			exclude_files << args[i + 1]
			i += 2
			continue
		}

		if arg.starts_with('--include=') {
			value := arg['--include='.len..]
			if value.len > 0 {
				include_files << value
			}
			i++
			continue
		}
		if arg == '--include' {
			if i + 1 >= args.len {
				eprintln('grep: option --include requires an argument')
				exit(1)
			}
			include_files << args[i + 1]
			i += 2
			continue
		}

		filtered << arg
		i++
	}

	return filtered, exclude_files, exclude_dirs, include_files
}

fn path_is_excluded(path string, patterns []string) bool {
	if patterns.len == 0 {
		return false
	}

	name := os.file_name(path).to_lower()
	for pattern in patterns {
		if name == pattern.to_lower() {
			return true
		}
		// Simple glob: *.ext
		p := pattern.to_lower()
		if p.starts_with('*') {
			suffix := p[1..]
			if name.ends_with(suffix) {
				return true
			}
		}
	}
	return false
}

fn path_is_included(path string, patterns []string) bool {
	if patterns.len == 0 {
		return true // no include filter = include all
	}

	name := os.file_name(path).to_lower()
	for pattern in patterns {
		p := pattern.to_lower()
		if name == p {
			return true
		}
		// Simple glob: *.ext
		if p.starts_with('*') {
			suffix := p[1..]
			if name.ends_with(suffix) {
				return true
			}
		}
	}
	return false
}

const default_exclude_dirs = [
	'.git',
	'node_modules',
	'vendor',
	'.angular',
	'.next',
	'.nuxt',
	'__pycache__',
	'.venv',
	'venv',
	'.tox',
	'dist',
	'build',
	'target',
	'.idea',
	'.vscode',
	'.pytest_cache',
	'coverage',
	'.nyc_output',
]

// is_binary_extension returns true for well-known binary file extensions.
// Called before opening a file so we never waste I/O or memory on them.
fn is_binary_extension(path string) bool {
	name := os.file_name(path).to_lower()
	dot_idx := name.last_index('.') or { return false }
	ext := name[dot_idx..]
	return ext in [
		// executables / libs
		'.exe', '.dll', '.so', '.dylib', '.lib', '.obj', '.pdb', '.a', '.o',
		// images
		'.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.tiff', '.webp', '.svg',
		// audio / video
		'.mp3', '.mp4', '.wav', '.flac', '.ogg', '.avi', '.mkv', '.mov', '.webm',
		// archives
		'.zip', '.tar', '.gz', '.bz2', '.xz', '.7z', '.rar', '.zst',
		// documents (binary formats)
		'.pdf', '.docx', '.xlsx', '.pptx', '.odt', '.ods',
		// databases / misc binary
		'.bin', '.dat', '.img', '.iso', '.class', '.pyc', '.pyo',
		'.wasm', '.db', '.sqlite', '.sqlite3',
		// fonts
		'.ttf', '.otf', '.woff', '.woff2', '.eot',
		// packages
		'.apk', '.ipa', '.deb', '.rpm', '.msi', '.cab',
	]
}
