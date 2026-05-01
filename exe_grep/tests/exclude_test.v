module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'grep.exe')
const test_root = 'test_grep_excludes'

fn test_setup() {
	if os.exists(test_root) {
		os.rmdir_all(test_root) or { }
	}
	os.mkdir_all(os.join_path(test_root, '.git')) or { panic(err) }
	os.mkdir_all(os.join_path(test_root, 'nested')) or { panic(err) }
	os.write_file(os.join_path(test_root, 'keep.txt'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, '.git', 'ignored.txt'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, 'nested', 'taubinha.sqlite'), 'MATCH\n') or { panic(err) }
}

fn test_cleanup() {
	os.rmdir_all(test_root) or { }
}

fn test_grep_exclude_dir_and_file() {
	test_setup()
	res := os.execute('${exe_path} -R --exclude-dir=.git --exclude=taubinha.sqlite MATCH ${test_root}')
	assert res.exit_code == 0
	assert res.output.contains('keep.txt')
	assert !res.output.contains('ignored.txt')
	assert !res.output.contains('taubinha.sqlite')
	test_cleanup()
}

fn test_grep_exclude_file_without_recursive() {
	test_setup()
	res := os.execute('${exe_path} --exclude=taubinha.sqlite MATCH ${os.join_path(test_root, "keep.txt")} ${os.join_path(test_root, "nested", "taubinha.sqlite")}')
	assert res.exit_code == 0
	assert res.output.contains('keep.txt')
	assert !res.output.contains('taubinha.sqlite')
	test_cleanup()
}
