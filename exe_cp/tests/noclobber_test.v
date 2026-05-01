module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'cp.exe')

fn test_setup() {
	os.write_file('cp_src.txt', 'source') or { }
	os.write_file('cp_dest.txt', 'dest') or { }
}

fn test_teardown() {
	os.rm('cp_src.txt') or { }
	os.rm('cp_dest.txt') or { }
	os.rm('cp_new.txt') or { }
}

fn test_cp_no_clobber() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} -n cp_src.txt cp_dest.txt')
	assert res.exit_code == 0
	
	// dest não deve ter sido alterado
	content := os.read_file('cp_dest.txt') or { '' }
	assert content == 'dest'
}

fn test_cp_no_clobber_success() {
	test_setup()
	defer { test_teardown() }
	
	res := os.execute('${exe_path} -n cp_src.txt cp_new.txt')
	assert res.exit_code == 0
	
	// novo destino deve ter o conteúdo do source
	content := os.read_file('cp_new.txt') or { '' }
	assert content == 'source'
}
