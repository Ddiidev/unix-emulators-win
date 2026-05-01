module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'mkdir.exe')

fn test_mkdir_basic() {
	os.rmdir_all('test_dir') or { }
	res := os.execute('${exe_path} test_dir')
	assert res.exit_code == 0
	assert os.is_dir('test_dir')
	os.rmdir('test_dir') or { }
}

fn test_mkdir_parents() {
	os.rmdir_all('p1') or { }
	res := os.execute('${exe_path} -p p1/p2/p3')
	assert res.exit_code == 0
	assert os.is_dir('p1/p2/p3')
	os.rmdir_all('p1') or { }
}

fn test_mkdir_error() {
	os.write_file('file_exists', 'test') or { }
	res := os.execute('${exe_path} file_exists')
	assert res.exit_code != 0
	os.rm('file_exists') or { }
}
