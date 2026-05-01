module tests

import os
import time

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'touch.exe')

fn test_setup() {
	os.write_file('touch_test.txt', 'test') or { }
	// Voltar no tempo para termos uma diferença clara
	old_time := int(time.now().unix() - 86400) // -1 day
	os.utime('touch_test.txt', old_time, old_time) or { }
}

fn test_teardown() {
	os.rm('touch_test.txt') or { }
}

fn test_touch_access_only() {
	test_setup()
	defer { test_teardown() }
	
	stat_before := os.stat('touch_test.txt') or { return }
	
	res := os.execute('${exe_path} -a touch_test.txt')
	assert res.exit_code == 0
	
	stat_after := os.stat('touch_test.txt') or { return }
	
	// Acesso mudou, modificação ficou igual
	assert stat_after.atime > stat_before.atime
	assert stat_after.mtime == stat_before.mtime
}

fn test_touch_mod_only() {
	test_setup()
	defer { test_teardown() }
	
	stat_before := os.stat('touch_test.txt') or { return }
	
	res := os.execute('${exe_path} -m touch_test.txt')
	assert res.exit_code == 0
	
	stat_after := os.stat('touch_test.txt') or { return }
	
	// Modificação mudou, acesso ficou igual
	assert stat_after.mtime > stat_before.mtime
	assert stat_after.atime == stat_before.atime
}
