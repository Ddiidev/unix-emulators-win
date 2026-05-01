module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'tail.exe')
const test_file = 'tail_seekend_test.txt'

fn test_setup() {
	mut content := ''
	for i in 1 .. 21 {
		content += 'line ${i}\n'
	}
	os.write_file(test_file, content) or { }
}

fn test_teardown() {
	os.rm(test_file) or { }
}

fn test_tail_seekend_default() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} ${test_file}')
	assert res.exit_code == 0
	assert !res.output.contains('line 10')
	assert res.output.contains('line 11')
	assert res.output.contains('line 20')
}

fn test_tail_seekend_n3() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} -n 3 ${test_file}')
	assert res.exit_code == 0
	assert !res.output.contains('line 17')
	assert res.output.contains('line 18')
	assert res.output.contains('line 19')
	assert res.output.contains('line 20')
}

fn test_tail_verbose_quiet() {
	test_setup()
	defer { test_teardown() }
	
	// Default: no header for single file
	res1 := os.execute('${exe_path} -n 1 ${test_file}')
	assert !res1.output.contains('==>')
	
	// Verbose: force header
	res2 := os.execute('${exe_path} -v -n 1 ${test_file}')
	assert res2.output.contains('==>')
	
	// Quiet: suppress header even for multiple files
	os.write_file('temp2.txt', 'a\n') or {}
	res3 := os.execute('${exe_path} -q -n 1 ${test_file} temp2.txt')
	assert !res3.output.contains('==>')
	os.rm('temp2.txt') or {}
}
