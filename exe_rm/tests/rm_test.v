module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'rm.exe')

fn test_rm_file() {
	os.write_file('temp.txt', 'test') or { }
	res := os.execute('${exe_path} temp.txt')
	assert res.exit_code == 0
	assert !os.exists('temp.txt')
}

fn test_rm_recursive() {
	os.mkdir_all('temp_dir/a/b') or { }
	os.write_file('temp_dir/a/b/file.txt', 'test') or { }
	res := os.execute('${exe_path} -r temp_dir')
	assert res.exit_code == 0
	assert !os.exists('temp_dir')
}

fn test_rm_force() {
	res := os.execute('${exe_path} -f nonexistent_file_999')
	assert res.exit_code == 0
}

fn test_rm_error() {
	res := os.execute('${exe_path} nonexistent_file_999')
	assert res.exit_code != 0
}
