module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'ls.exe')

fn test_ls_basic() {
	res := os.execute('${exe_path} .')
	assert res.exit_code == 0
	assert res.output.len > 0
}

fn test_ls_all() {
	res := os.execute('${exe_path} -a .')
	assert res.exit_code == 0
	assert res.output.contains('.')
	assert res.output.contains('..')
}

fn test_ls_long() {
	res := os.execute('${exe_path} -l .')
	assert res.exit_code == 0
	// Check for common permission pattern
	assert res.output.contains('rwx') 
}

fn test_ls_recursive() {
	res := os.execute('${exe_path} -R .')
	assert res.exit_code == 0
	assert res.output.contains('tests:')
}

fn test_ls_sort_size() {
	res := os.execute('${exe_path} -S .')
	assert res.exit_code == 0
}

fn test_ls_not_found() {
	res := os.execute('${exe_path} nonexistent_folder_123')
	assert res.exit_code != 0
	assert res.output.contains('cannot access')
}
