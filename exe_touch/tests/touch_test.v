module tests

import os
import time

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'touch.exe')

fn test_touch_create() {
	os.rm('touch_new_file.txt') or { }
	res := os.execute('${exe_path} touch_new_file.txt')
	assert res.exit_code == 0
	assert os.exists('touch_new_file.txt')
	os.rm('touch_new_file.txt') or { }
}

fn test_touch_update() {
	os.write_file('touch_existing.txt', 'test') or { }
	// Wait a bit to ensure timestamp changes
	time.sleep(1100 * time.millisecond) 
	
	old_time := os.file_last_mod_unix('touch_existing.txt')
	res := os.execute('${exe_path} touch_existing.txt')
	assert res.exit_code == 0
	
	new_time := os.file_last_mod_unix('touch_existing.txt')
	assert new_time > old_time
	os.rm('touch_existing.txt') or { }
}

fn test_touch_no_create() {
	os.rm('touch_no_create.txt') or { }
	res := os.execute('${exe_path} -c touch_no_create.txt')
	assert res.exit_code == 0
	assert !os.exists('touch_no_create.txt')
}
