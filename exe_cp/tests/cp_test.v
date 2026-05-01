module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'cp.exe')

fn test_cp_file() {
	os.write_file('cp_src_file.txt', 'hello') or { }
	os.rm('cp_dest_file.txt') or { }
	res := os.execute('${exe_path} cp_src_file.txt cp_dest_file.txt')
	assert res.exit_code == 0
	assert os.exists('cp_dest_file.txt')
	assert os.read_file('cp_dest_file.txt') or { '' } == 'hello'
	os.rm('cp_src_file.txt') or { }
	os.rm('cp_dest_file.txt') or { }
}

fn test_cp_recursive() {
	os.mkdir_all('cp_src_dir/sub') or { }
	os.write_file('cp_src_dir/sub/f.txt', 'data') or { }
	res := os.execute('${exe_path} -r cp_src_dir cp_dest_dir')
	assert res.exit_code == 0
	assert os.is_dir('cp_dest_dir/sub')
	assert os.exists('cp_dest_dir/sub/f.txt')
	os.rmdir_all('cp_src_dir') or { }
	os.rmdir_all('cp_dest_dir') or { }
}

fn test_cp_error() {
	res := os.execute('${exe_path} nonexistent_file cp_dest_err.txt')
	assert res.exit_code != 0
}
