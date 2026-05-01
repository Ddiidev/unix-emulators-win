module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'uniq.exe')

fn test_setup() {
	os.write_file('uniq_case_test.txt', 'Line\nline\nLINE\nOther\nother') or { }
}

fn test_teardown() {
	os.rm('uniq_case_test.txt') or { }
}

fn test_uniq_case_sensitive_default() {
	test_setup()
	defer { test_teardown() }
	
	// Default diferencia maiúsculas de minúsculas
	res := os.execute('${exe_path} uniq_case_test.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split('\n')
	assert lines.len == 5 // Nenhuma linha é removida
}

fn test_uniq_ignore_case() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} -i uniq_case_test.txt')
	assert res.exit_code == 0
	lines := res.output.trim_space().split('\n')
	
	// Deve manter apenas o primeiro "Line" e o primeiro "Other"
	assert lines.len == 2
	assert lines[0] == 'Line'
	assert lines[1] == 'Other'
}

fn test_uniq_ignore_case_count() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} -i -c uniq_case_test.txt')
	assert res.exit_code == 0
	
	assert res.output.contains('3 Line')
	assert res.output.contains('2 Other')
}
