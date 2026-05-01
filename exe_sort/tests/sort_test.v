module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'sort.exe')

fn test_sort_basic() {
	os.write_file('sort_temp.txt', 'c\na\nb') or { }
	res := os.execute('${exe_path} sort_temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines == ['a', 'b', 'c']
	os.rm('sort_temp.txt') or { }
}

fn test_sort_numeric() {
	os.write_file('sort_temp.txt', '10\n1\n2') or { }
	res := os.execute('${exe_path} -n sort_temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines == ['1', '2', '10']
	os.rm('sort_temp.txt') or { }
}

fn test_sort_reverse() {
	os.write_file('sort_temp.txt', 'a\nb\nc') or { }
	res := os.execute('${exe_path} -r sort_temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines == ['c', 'b', 'a']
	os.rm('sort_temp.txt') or { }
}
