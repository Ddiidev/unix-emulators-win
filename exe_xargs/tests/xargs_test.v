module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'xargs.exe')

fn test_echo() {
	res := os.execute('echo world | ${exe_path} echo hello')
	assert res.exit_code == 0
	assert res.output.contains('hello world')
}

fn test_multiple_args() {
	res := os.execute('echo file1 file2 | ${exe_path} echo items:')
	assert res.exit_code == 0
	assert res.output.contains('items: file1 file2')
}

fn test_verbose() {
	res := os.execute('echo arg | ${exe_path} -t echo')
	assert res.exit_code == 0
	assert res.output.contains('arg')
}
