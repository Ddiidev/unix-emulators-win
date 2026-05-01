module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'findd.exe')

fn test_setup() {
	os.rmdir_all('test_find_root') or { }
	os.mkdir_all('test_find_root/a/b') or { }
	os.write_file('test_find_root/a/file1.txt', 'test') or { }
	os.write_file('test_find_root/a/b/file2.log', 'test') or { }
}

fn test_cleanup() {
	os.rmdir_all('test_find_root') or { }
}

fn normalize_out(s string) string {
	return s.replace('\\', '/')
}

fn test_find_basic() {
	test_setup()
	res := os.execute('${exe_path} test_find_root')
	assert res.exit_code == 0
	out := normalize_out(res.output)
	assert out.contains('test_find_root/a/file1.txt')
	assert out.contains('test_find_root/a/b/file2.log')
	test_cleanup()
}

fn test_find_name() {
	test_setup()
	res := os.execute('${exe_path} test_find_root -name "*.txt"')
	assert res.exit_code == 0
	out := normalize_out(res.output)
	assert out.contains('file1.txt')
	assert !out.contains('file2.log')
	test_cleanup()
}

fn test_find_type() {
	test_setup()
	res := os.execute('${exe_path} test_find_root -type d')
	assert res.exit_code == 0
	out := normalize_out(res.output)
	assert out.contains('test_find_root/a/b')
	assert !out.contains('file1.txt')
	test_cleanup()
}
