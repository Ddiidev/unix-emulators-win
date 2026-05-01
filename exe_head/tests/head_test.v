module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'head.exe')

fn test_head_basic() {
	os.write_file('temp.txt', '1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12') or { }
	res := os.execute('${exe_path} -n 3 temp.txt')
	assert res.exit_code == 0
	// Last check: split into lines and check count
	lines := res.output.trim_space().split_into_lines()
	assert lines.len == 3
	assert lines[0] == '1'
	assert lines[1] == '2'
	assert lines[2] == '3'
	os.rm('temp.txt') or { }
}

fn test_head_bytes() {
	os.write_file('temp.txt', 'hello world') or { }
	res := os.execute('${exe_path} -c 5 temp.txt')
	assert res.exit_code == 0
	assert res.output == 'hello'
	os.rm('temp.txt') or { }
}
