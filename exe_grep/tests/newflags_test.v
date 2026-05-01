module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'grep.exe')

fn test_setup() {
	os.mkdir('grep_newflags_dir') or { }
	os.write_file('grep_newflags_dir/file1.txt', 'hello match world\nno target here\nmatch again') or { }
	os.write_file('grep_newflags_dir/file2.log', 'error: something went wrong\nmatch this log') or { }
	os.write_file('grep_newflags_dir/file3.txt', 'clean file\nnothing to see') or { }
}

fn test_teardown() {
	os.rmdir_all('grep_newflags_dir') or { }
}

fn test_grep_only_matching() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} --color=never -o match grep_newflags_dir/file1.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines.len == 2
	assert lines[0].trim_space() == 'match'
	assert lines[1].trim_space() == 'match'
}

fn test_grep_files_without_match() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} --color=never -L match grep_newflags_dir/file1.txt grep_newflags_dir/file3.txt')
	assert res.exit_code == 0
	assert res.output.contains('file3.txt')
	assert !res.output.contains('file1.txt')
}

fn test_grep_max_count() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} --color=never -m 1 match grep_newflags_dir/file1.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split('\n')
	assert lines.len == 1 // Only the first match should be printed
	assert lines[0].contains('hello match world')
}

fn test_grep_include() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} --color=never -r match --include=*.txt grep_newflags_dir/')
	assert res.exit_code == 0
	assert res.output.contains('file1.txt')
	assert !res.output.contains('file2.log') // Should be skipped
}
