module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'uniq.exe')

fn test_uniq_basic() {
	os.write_file('uniq_temp.txt', 'a\na\nb\nc\nc\nc') or { }
	res := os.execute('${exe_path} uniq_temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines == ['a', 'b', 'c']
	os.rm('uniq_temp.txt') or { }
}

fn test_uniq_count() {
	os.write_file('uniq_temp.txt', 'a\na\nb') or { }
	res := os.execute('${exe_path} -c uniq_temp.txt')
	assert res.exit_code == 0
	assert res.output.contains('2 a')
	assert res.output.contains('1 b')
	os.rm('uniq_temp.txt') or { }
}
