module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'head.exe')

fn test_setup() {
	os.write_file('head_test1.txt', '1') or { }
	os.write_file('head_test2.txt', '2') or { }
}

fn test_teardown() {
	os.rm('head_test1.txt') or { }
	os.rm('head_test2.txt') or { }
}

fn test_head_verbose() {
	test_setup()
	defer { test_teardown() }
	
	// -v força mostrar o header mesmo para apenas um arquivo
	res := os.execute('${exe_path} -v head_test1.txt')
	assert res.exit_code == 0
	assert res.output.contains('==> head_test1.txt <==')
}

fn test_head_quiet() {
	test_setup()
	defer { test_teardown() }
	
	// -q suprime header mesmo com múltiplos arquivos
	res := os.execute('${exe_path} -q head_test1.txt head_test2.txt')
	assert res.exit_code == 0
	assert !res.output.contains('==>')
	assert res.output.contains('1')
	assert res.output.contains('2')
}

fn test_head_multiple_files_default() {
	test_setup()
	defer { test_teardown() }
	
	// Por padrão mostra header para múltiplos arquivos
	res := os.execute('${exe_path} head_test1.txt head_test2.txt')
	assert res.exit_code == 0
	assert res.output.contains('==> head_test1.txt <==')
	assert res.output.contains('==> head_test2.txt <==')
}
