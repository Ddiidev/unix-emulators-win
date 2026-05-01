module tests

import os
import time

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'touch.exe')

fn test_touch_create() {
	os.rm('new_file.txt') or { }
	res := os.execute('${exe_path} new_file.txt')
	assert res.exit_code == 0
	assert os.exists('new_file.txt')
	os.rm('new_file.txt') or { }
}

fn test_touch_update() {
	os.write_file('existing.txt', 'test') or { }
	// Wait a bit to ensure timestamp changes
	time.sleep(1100 * time.millisecond) 
	
	old_time := os.file_last_mod_unix('existing.txt')
	res := os.execute('${exe_path} existing.txt')
	assert res.exit_code == 0
	
	new_time := os.file_last_mod_unix('existing.txt')
	assert new_time > old_time
	os.rm('existing.txt') or { }
}

fn test_touch_no_create() {
	os.rm('no_create.txt') or { }
	res := os.execute('${exe_path} -c no_create.txt')
	assert res.exit_code == 0
	assert !os.exists('no_create.txt')
}
