module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'tail.exe')

fn test_tail_basic() {
	os.write_file('temp.txt', '1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n11\n12\n') or { }
	res := os.execute('${exe_path} -n 3 temp.txt')
	assert res.exit_code == 0
	// Last 3 lines: 10, 11, 12
	lines := res.output.trim_space().split_into_lines()
	assert lines.len == 3
	assert lines.contains('10')
	assert lines.contains('11')
	assert lines.contains('12')
	os.rm('temp.txt') or { }
}
