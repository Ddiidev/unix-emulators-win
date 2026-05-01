module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'cp.exe')

fn test_cp_file() {
	os.write_file('src.txt', 'hello') or { }
	os.rm('dest.txt') or { }
	res := os.execute('${exe_path} src.txt dest.txt')
	assert res.exit_code == 0
	assert os.exists('dest.txt')
	assert os.read_file('dest.txt') or { '' } == 'hello'
	os.rm('src.txt') or { }
	os.rm('dest.txt') or { }
}

fn test_cp_recursive() {
	os.mkdir_all('src_dir/sub') or { }
	os.write_file('src_dir/sub/f.txt', 'data') or { }
	res := os.execute('${exe_path} -r src_dir dest_dir')
	assert res.exit_code == 0
	assert os.is_dir('dest_dir/sub')
	assert os.exists('dest_dir/sub/f.txt')
	os.rmdir_all('src_dir') or { }
	os.rmdir_all('dest_dir') or { }
}

fn test_cp_error() {
	res := os.execute('${exe_path} nonexistent_file dest.txt')
	assert res.exit_code != 0
}
