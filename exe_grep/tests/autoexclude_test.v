module tests

import os

const exe_path = os.join_path(os.dir(@FILE), '..', '..', '..', 'grep.exe')
const test_root = 'test_grep_autoexclude'

fn test_setup() {
	if os.exists(test_root) {
		os.rmdir_all(test_root) or {}
	}
	os.mkdir_all(os.join_path(test_root, 'node_modules', '.cache')) or { panic(err) }
	os.mkdir_all(os.join_path(test_root, '.git', 'refs')) or { panic(err) }
	os.mkdir_all(os.join_path(test_root, 'vendor', 'pkg')) or { panic(err) }
	os.mkdir_all(os.join_path(test_root, '.angular', 'cache')) or { panic(err) }
	os.mkdir_all(os.join_path(test_root, 'dist')) or { panic(err) }
	os.mkdir_all(os.join_path(test_root, 'build')) or { panic(err) }
	os.mkdir_all(os.join_path(test_root, 'src', 'app')) or { panic(err) }
	os.write_file(os.join_path(test_root, 'node_modules', 'lib.js'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, 'node_modules', '.cache', 'data.json'), 'MATCH\n') or {
		panic(err)
	}
	os.write_file(os.join_path(test_root, '.git', 'config'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, '.git', 'refs', 'HEAD'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, 'vendor', 'autoload.php'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, 'vendor', 'pkg', 'Class.php'), 'MATCH\n') or {
		panic(err)
	}
	os.write_file(os.join_path(test_root, '.angular', 'cache', 'modules'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, 'dist', 'bundle.js'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, 'build', 'output.txt'), 'MATCH\n') or { panic(err) }
	os.write_file(os.join_path(test_root, 'src', 'app', 'component.ts'), 'MATCH\n') or { panic(err) }
}

fn test_cleanup() {
	os.rmdir_all(test_root) or {}
}

// Verifies that default exclude directories are silently skipped during
// recursive scans. node_modules, .git, vendor, .angular, dist, build
// should all be excluded when the user does NOT pass --exclude-dir.
fn test_recursive_auto_excludes_heavy_dirs() {
	test_setup()
	res := os.execute('${exe_path} -R MATCH ${test_root}')
	assert res.exit_code == 0
	assert res.output.contains('src')
	assert !res.output.contains('node_modules')
	assert !res.output.contains('.git')
	assert !res.output.contains('vendor')
	assert !res.output.contains('.angular')
	assert !res.output.contains('dist')
	assert !res.output.contains('build')
	test_cleanup()
}
