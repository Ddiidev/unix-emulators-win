module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'cat.exe')
const test_file = 'test_cat_data.txt'

fn test_setup() {
	os.write_file(test_file, 'line 1\nline 2\n\nline 4\n') or { panic(err) }
}

fn test_cleanup() {
	os.rm(test_file) or { }
}

fn normalize(s string) string {
	return s.replace('\r\n', '\n').trim_space()
}

fn test_cat_basic() {
	test_setup()
	res := os.execute('${exe_path} ${test_file}')
	assert res.exit_code == 0
	assert normalize(res.output) == 'line 1\nline 2\n\nline 4'
	test_cleanup()
}

fn test_cat_number() {
	test_setup()
	res := os.execute('${exe_path} -n ${test_file}')
	assert res.exit_code == 0
	assert normalize(res.output).contains('1\tline 1')
	assert normalize(res.output).contains('2\tline 2')
	assert normalize(res.output).contains('3\t')
	assert normalize(res.output).contains('4\tline 4')
	test_cleanup()
}

fn test_cat_number_nonblank() {
	test_setup()
	res := os.execute('${exe_path} -b ${test_file}')
	assert res.exit_code == 0
	assert normalize(res.output).contains('1\tline 1')
	assert normalize(res.output).contains('2\tline 2')
	// Line 4 is the 3rd non-blank line
	assert normalize(res.output).contains('3\tline 4')
	test_cleanup()
}

fn test_cat_squeeze() {
	os.write_file(test_file, 'line 1\n\n\nline 4\n') or { panic(err) }
	res := os.execute('${exe_path} -s ${test_file}')
	assert res.exit_code == 0
	assert normalize(res.output) == 'line 1\n\nline 4'
	test_cleanup()
}

fn test_cat_show_ends() {
	test_setup()
	res := os.execute('${exe_path} -E ${test_file}')
	assert res.exit_code == 0
	assert normalize(res.output).contains('line 1$')
	test_cleanup()
}
