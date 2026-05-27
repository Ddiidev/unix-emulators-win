module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'head.exe')

fn test_head_shorthand_3_lines() {
	os.write_file('head_shorthand_temp.txt', '1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n') or {}
	res := os.execute('${exe_path} -3 head_shorthand_temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines.len == 3
	assert lines[0] == '1'
	assert lines[1] == '2'
	assert lines[2] == '3'
	os.rm('head_shorthand_temp.txt') or {}
}

fn test_head_shorthand_1_line() {
	os.write_file('head_shorthand_temp.txt', 'first\nsecond\nthird\n') or {}
	res := os.execute('${exe_path} -1 head_shorthand_temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines.len == 1
	assert lines[0] == 'first'
	os.rm('head_shorthand_temp.txt') or {}
}

fn test_head_shorthand_more_than_file() {
	// Request more lines than the file has — should print everything without error
	os.write_file('head_shorthand_temp.txt', 'a\nb\nc\n') or {}
	res := os.execute('${exe_path} -30 head_shorthand_temp.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split_into_lines()
	assert lines.len == 3
	assert lines[0] == 'a'
	assert lines[1] == 'b'
	assert lines[2] == 'c'
	os.rm('head_shorthand_temp.txt') or {}
}

fn test_head_shorthand_equivalent_to_n() {
	// -5 should produce the same output as -n 5
	os.write_file('head_shorthand_temp.txt', '1\n2\n3\n4\n5\n6\n7\n8\n9\n10\n') or {}
	res_short := os.execute('${exe_path} -5 head_shorthand_temp.txt')
	res_long := os.execute('${exe_path} -n 5 head_shorthand_temp.txt')
	assert res_short.exit_code == 0
	assert res_long.exit_code == 0
	assert res_short.output == res_long.output
	os.rm('head_shorthand_temp.txt') or {}
}
