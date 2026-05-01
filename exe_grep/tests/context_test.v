module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'grep.exe')
const test_file = 'context_test_data.txt'

fn test_setup() {
	os.write_file(test_file, 'line 1\nline 2\nMATCH\nline 4\nline 5\nOTHER\nline 7\nMATCH\nline 9') or { panic(err) }
}

fn test_cleanup() {
	os.rm(test_file) or { }
}

fn test_grep_after_context() {
	test_setup()
	res := os.execute('${exe_path} --color=never -A 2 MATCH ${test_file}')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	// Should see MATCH, line 4, line 5, MATCH, line 9
	assert lines.contains('MATCH')
	assert lines.contains('line 4')
	assert lines.contains('line 5')
	assert lines.contains('line 9')
	test_cleanup()
}

fn test_grep_before_context() {
	test_setup()
	res := os.execute('${exe_path} --color=never -B 2 MATCH ${test_file}')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	// Should see line 1, line 2, MATCH, OTHER, line 7, MATCH
	assert lines.contains('line 1')
	assert lines.contains('line 2')
	assert lines.contains('OTHER')
	assert lines.contains('line 7')
	test_cleanup()
}

fn test_grep_context() {
	test_setup()
	res := os.execute('${exe_path} --color=never -C 1 MATCH ${test_file}')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	// MATCH1 context: line 2, MATCH, line 4
	// MATCH2 context: line 7, MATCH, line 9
	assert lines.contains('line 2')
	assert lines.contains('line 4')
	assert lines.contains('line 7')
	assert lines.contains('line 9')
	test_cleanup()
}
