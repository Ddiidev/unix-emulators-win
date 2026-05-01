module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'mv.exe')

fn test_setup() {
	os.write_file('mv_src.txt', 'source') or { }
	os.write_file('mv_dest.txt', 'dest') or { }
}

fn test_teardown() {
	os.rm('mv_src.txt') or { }
	os.rm('mv_dest.txt') or { }
	os.rm('mv_new.txt') or { }
}

fn test_mv_no_clobber() {
	test_setup()
	defer { test_teardown() }
	
	// Deve pular silenciosamente
	res := os.execute('${exe_path} -n mv_src.txt mv_dest.txt')
	assert res.exit_code == 0
	
	// source ainda deve existir
	assert os.exists('mv_src.txt')
	
	// dest não deve ter sido alterado
	content := os.read_file('mv_dest.txt') or { '' }
	assert content == 'dest'
}

fn test_mv_no_clobber_success() {
	test_setup()
	defer { test_teardown() }
	
	// Deve mover já que destino não existe
	res := os.execute('${exe_path} -n mv_src.txt mv_new.txt')
	assert res.exit_code == 0
	
	// source não deve existir
	assert !os.exists('mv_src.txt')
	
	// novo destino deve ter o conteúdo do source
	content := os.read_file('mv_new.txt') or { '' }
	assert content == 'source'
}
