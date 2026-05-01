module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'mkdir.exe')

fn test_mkdir_basic() {
	os.rmdir_all('mkdir_test_dir') or { }
	res := os.execute('${exe_path} mkdir_test_dir')
	assert res.exit_code == 0
	assert os.is_dir('mkdir_test_dir')
	os.rmdir('mkdir_test_dir') or { }
}

fn test_mkdir_parents() {
	os.rmdir_all('mkdir_p1') or { }
	res := os.execute('${exe_path} -p mkdir_p1/p2/p3')
	assert res.exit_code == 0
	assert os.is_dir('mkdir_p1/p2/p3')
	os.rmdir_all('mkdir_p1') or { }
}

fn test_mkdir_error() {
	os.write_file('mkdir_file_exists', 'test') or { }
	res := os.execute('${exe_path} mkdir_file_exists')
	assert res.exit_code != 0
	os.rm('mkdir_file_exists') or { }
}
