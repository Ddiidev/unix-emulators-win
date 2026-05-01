module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'pwd.exe')

fn test_pwd() {
	res := os.execute('${exe_path}')
	assert res.exit_code == 0
	// Use case-insensitive comparison for Windows paths and allow for trailing slashes or case differences
	assert res.output.trim_space().to_lower().replace('\\', '/') == os.getwd().to_lower().replace('\\', '/')
}
