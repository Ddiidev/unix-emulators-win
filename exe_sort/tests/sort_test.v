module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'sort.exe')

fn test_sort_basic() {
	os.write_file('temp.txt', 'c\na\nb') or { }
	res := os.execute('${exe_path} temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines == ['a', 'b', 'c']
	os.rm('temp.txt') or { }
}

fn test_sort_numeric() {
	os.write_file('temp.txt', '10\n1\n2') or { }
	res := os.execute('${exe_path} -n temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines == ['1', '2', '10']
	os.rm('temp.txt') or { }
}

fn test_sort_reverse() {
	os.write_file('temp.txt', 'a\nb\nc') or { }
	res := os.execute('${exe_path} -r temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines == ['c', 'b', 'a']
	os.rm('temp.txt') or { }
}
