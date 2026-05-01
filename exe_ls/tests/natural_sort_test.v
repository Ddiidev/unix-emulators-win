module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'ls.exe')

fn test_setup() {
	os.mkdir('ls_natural_test_dir') or { }
	os.write_file('ls_natural_test_dir/file1.txt', '') or { }
	os.write_file('ls_natural_test_dir/file10.txt', '') or { }
	os.write_file('ls_natural_test_dir/file2.txt', '') or { }
}

fn test_teardown() {
	os.rmdir_all('ls_natural_test_dir') or { }
}

fn test_ls_natural_sort() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} -v -1 ls_natural_test_dir')
	assert res.exit_code == 0
	lines := res.output.trim_space().split('\n')
	
	// Deve ser: file1.txt, file2.txt, file10.txt
	assert lines.len >= 3
	mut idx1 := -1
	mut idx2 := -1
	mut idx10 := -1
	
	for i, line in lines {
		if line.contains('file1.txt') { idx1 = i }
		if line.contains('file2.txt') { idx2 = i }
		if line.contains('file10.txt') { idx10 = i }
	}
	
	assert idx1 < idx2
	assert idx2 < idx10
}
