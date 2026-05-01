module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'mv.exe')

fn test_mv_file() {
	os.write_file('src.txt', 'hello') or { }
	os.rm('dest.txt') or { }
	res := os.execute('${exe_path} src.txt dest.txt')
	assert res.exit_code == 0
	assert os.exists('dest.txt')
	assert !os.exists('src.txt')
	os.rm('dest.txt') or { }
}

fn test_mv_dir() {
	os.mkdir_all('src_dir') or { }
	os.write_file('src_dir/f.txt', 'data') or { }
	res := os.execute('${exe_path} src_dir dest_dir')
	assert res.exit_code == 0
	assert os.is_dir('dest_dir')
	assert os.exists('dest_dir/f.txt')
	assert !os.exists('src_dir')
	os.rmdir_all('dest_dir') or { }
}
