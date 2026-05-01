module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'findd.exe')
const test_dir = os.join_path(os.dir(@FILE), 'test_advanced')

fn test_main() {
	if os.exists(test_dir) { os.rmdir_all(test_dir) or {} }
	os.mkdir_all(test_dir) or { panic(err) }
	
	os.mkdir(os.join_path(test_dir, 'dir1')) or {}
	os.mkdir(os.join_path(test_dir, 'dir1/subdir1')) or {}
	os.create(os.join_path(test_dir, 'file1.txt')) or {}
	os.create(os.join_path(test_dir, 'file2.log')) or {}
	os.create(os.join_path(test_dir, 'dir1/file3.txt')) or {}
}

fn test_maxdepth() {
	res := os.execute('${exe_path} ${test_dir} -maxdepth 1 -type f')
	assert res.exit_code == 0
	assert res.output.contains('file1.txt')
	assert res.output.contains('file2.log')
	assert !res.output.contains('file3.txt')
}

fn test_or_logic() {
	// OR between two iname patterns
	res := os.execute('${exe_path} ${test_dir} -iname "*.txt" -o -iname "*.log"')
	assert res.exit_code == 0
	assert res.output.contains('file1.txt')
	assert res.output.contains('file2.log')
	assert res.output.contains('file3.txt')
}

fn test_or_with_type() {
	// Files OR directories named 'dir1'
	res := os.execute('${exe_path} ${test_dir} -type f -o -name "dir1"')
	assert res.exit_code == 0
	assert res.output.contains('file1.txt')
	assert res.output.contains('dir1')
	assert !res.output.contains('subdir1')
}

fn test_cleanup() {
	os.rmdir_all(test_dir) or {}
}
