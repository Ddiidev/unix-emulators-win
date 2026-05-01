import os

fn main() {
	dirs := os.ls('.') or { return }
	for d in dirs {
		if d.starts_with('exe_') && os.is_dir(d) {
			test_dir := os.join_path(d, 'tests')
			if os.is_dir(test_dir) {
				test_files := os.ls(test_dir) or { continue }
				for f in test_files {
					if f.ends_with('_test.v') {
						path := os.join_path(test_dir, f)
						content := os.read_file(path) or { continue }
						exe_name := d.replace('exe_', '')
						new_content := content.replace('os.join_path(os.dir(@FILE), \'..\', \'.exe\')', 'os.join_path(os.dir(@FILE), \'..\', \'${exe_name}.exe\')')
						os.write_file(path, new_content) or { }
					}
				}
			}
		}
	}
}
