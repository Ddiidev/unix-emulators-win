module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'findd.exe')

fn test_setup() {
	os.mkdir('find_perf_test_dir') or { }
	os.write_file('find_perf_test_dir/file1.txt', '1') or { }
	os.write_file('find_perf_test_dir/file2.log', '2') or { }
	os.write_file('find_perf_test_dir/FiLe3.TXT', '3') or { }
	os.write_file('find_perf_test_dir/empty.txt', '') or { }
	os.mkdir('find_perf_test_dir/subdir') or { }
	os.write_file('find_perf_test_dir/subdir/file4.txt', '4') or { }
}

fn test_teardown() {
	os.rmdir_all('find_perf_test_dir') or { }
}

fn test_find_name_glob() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} find_perf_test_dir -name *.txt')
	assert res.exit_code == 0
	assert res.output.contains('file1.txt')
	assert res.output.contains('empty.txt')
	assert res.output.contains('file4.txt')
	assert !res.output.contains('file2.log')
	assert !res.output.contains('FiLe3.TXT') // case sensitive
}

fn test_find_iname() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} find_perf_test_dir -iname *.txt')
	assert res.exit_code == 0
	assert res.output.contains('file1.txt')
	assert res.output.contains('FiLe3.TXT')
	assert !res.output.contains('file2.log')
}

fn test_find_empty() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} find_perf_test_dir -empty')
	assert res.exit_code == 0
	assert res.output.contains('empty.txt')
	assert !res.output.contains('file1.txt')
}

fn test_find_or() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} find_perf_test_dir -name *.log -o -name empty.txt')
	assert res.exit_code == 0
	assert res.output.contains('file2.log')
	assert res.output.contains('empty.txt')
	assert !res.output.contains('file1.txt')
}
