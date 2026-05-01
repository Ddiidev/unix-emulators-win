module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'grep.exe')
const test_file = 'test_grep_data.txt'

fn test_setup() {
	os.write_file(test_file, 'apple\nBanana\ncherry\nApple pie\n') or { panic(err) }
}

fn test_cleanup() {
	os.rm(test_file) or { }
}

fn test_grep_basic() {
	test_setup()
	res := os.execute('${exe_path} --color=never "apple" ${test_file}')
	assert res.exit_code == 0
	assert res.output.contains('apple')
	assert !res.output.contains('Banana')
	test_cleanup()
}

fn test_grep_ignore_case() {
	test_setup()
	res := os.execute('${exe_path} --color=never -i "APPLE" ${test_file}')
	assert res.exit_code == 0
	assert res.output.contains('apple')
	assert res.output.contains('Apple pie')
	test_cleanup()
}

fn test_grep_invert() {
	test_setup()
	res := os.execute('${exe_path} --color=never -v "apple" ${test_file}')
	assert res.exit_code == 0
	assert !res.output.contains('apple')
	assert res.output.contains('Banana')
	test_cleanup()
}

fn test_grep_count() {
	test_setup()
	res := os.execute('${exe_path} --color=never -c "apple" ${test_file}')
	assert res.exit_code == 0
	assert res.output.trim_space() == '1'
	test_cleanup()
}

fn test_grep_no_match() {
	test_setup()
	res := os.execute('${exe_path} --color=never "nonexistent" ${test_file}')
	assert res.exit_code == 1
	test_cleanup()
}

fn test_grep_regex() {
	test_setup()
	res := os.execute('${exe_path} --color=never "^B.*a" ${test_file}')
	assert res.exit_code == 0
	assert res.output.contains('Banana')
	test_cleanup()
}
