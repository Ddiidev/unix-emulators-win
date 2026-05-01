module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'grep.exe')

fn test_setup() {
	os.write_file('ringbuf_test.txt', 'line 1\nline 2\nline 3\ntarget match\nline 5\nline 6') or { }
}

fn test_teardown() {
	os.rm('ringbuf_test.txt') or { }
}

fn test_grep_before_context_ringbuf() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} --color=never -B 2 target ringbuf_test.txt')
	assert res.exit_code == 0
	assert !res.output.contains('line 1')
	assert res.output.contains('line 2')
	assert res.output.contains('line 3')
	assert res.output.contains('target match')
}

fn test_grep_context_ringbuf() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} --color=never -C 1 target ringbuf_test.txt')
	assert res.exit_code == 0
	assert !res.output.contains('line 2')
	assert res.output.contains('line 3')
	assert res.output.contains('target match')
	assert res.output.contains('line 5')
	assert !res.output.contains('line 6')
}
