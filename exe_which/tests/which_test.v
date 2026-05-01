module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'which.exe')

fn test_which_found() {
	res := os.execute('${exe_path} ls')
	assert res.exit_code == 0
	assert res.output.to_lower().contains('ls.exe')
}

fn test_which_not_found() {
	res := os.execute('${exe_path} nonexistent_prog_999')
	assert res.exit_code != 0
}
