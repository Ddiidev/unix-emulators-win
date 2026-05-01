module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'mv.exe')

fn test_mv_file() {
	os.write_file('mv_src_file.txt', 'hello') or { }
	os.rm('mv_dest_file.txt') or { }
	res := os.execute('${exe_path} mv_src_file.txt mv_dest_file.txt')
	assert res.exit_code == 0
	assert os.exists('mv_dest_file.txt')
	assert !os.exists('mv_src_file.txt')
	os.rm('mv_dest_file.txt') or { }
}

fn test_mv_dir() {
	os.mkdir_all('mv_src_dir') or { }
	os.write_file('mv_src_dir/f.txt', 'data') or { }
	res := os.execute('${exe_path} mv_src_dir mv_dest_dir')
	assert res.exit_code == 0
	assert os.is_dir('mv_dest_dir')
	assert os.exists('mv_dest_dir/f.txt')
	assert !os.exists('mv_src_dir')
	os.rmdir_all('mv_dest_dir') or { }
}
