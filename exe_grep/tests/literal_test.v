module tests

import os

const exe_path = os.join_path('c:', 'Users', 'andre', 'bin', 'grep.exe')
const test_root = 'test_grep_literal'

fn test_setup() {
	if os.exists(test_root) {
		os.rmdir_all(test_root) or {}
	}
	os.mkdir_all(test_root) or { panic(err) }
	os.write_file(os.join_path(test_root, 'data.txt'), 'apple\nBanana\ncherry\nApple pie\n') or {
		panic(err)
	}
}

fn test_cleanup() {
	os.rmdir_all(test_root) or {}
}

// Literal pattern auto-detection: patterns without regex meta-chars should
// be treated as fixed strings. They must produce the same results as if
// they went through the regex engine.
fn test_literal_pattern_no_metachars() {
	test_setup()
	res := os.execute('${exe_path} --color=never "apple|Banana" ${os.join_path(test_root, "data.txt")}')
	assert res.exit_code == 0
	assert res.output.contains('apple')
	assert res.output.contains('Banana')
	assert !res.output.contains('cherry')
	test_cleanup()
}

fn test_literal_pattern_with_spaces() {
	test_setup()
	res := os.execute('${exe_path} --color=never "Apple pie|cherry" ${os.join_path(test_root, "data.txt")}')
	assert res.exit_code == 0
	assert res.output.contains('Apple pie')
	assert res.output.contains('cherry')
	test_cleanup()
}

fn test_literal_pattern_with_slash() {
	test_setup()
	res := os.execute('${exe_path} --color=never "app/le|Ban/ana" ${os.join_path(test_root, "data.txt")}')
	assert res.exit_code == 1
	test_cleanup()
}

// Literal pattern should still support -i (case insensitive) even in fixed-string mode.
fn test_literal_pattern_ignore_case() {
	test_setup()
	res := os.execute('${exe_path} --color=never -i "APPLE|BANANA" ${os.join_path(test_root, "data.txt")}')
	assert res.exit_code == 0
	assert res.output.contains('apple')
	assert res.output.contains('Banana')
	test_cleanup()
}

// Literal pattern should still support -v (invert match) in fixed-string mode.
fn test_literal_pattern_invert() {
	test_setup()
	res := os.execute('${exe_path} --color=never -v "apple|Banana" ${os.join_path(test_root, "data.txt")}')
	assert res.exit_code == 0
	assert !res.output.contains('apple')
	assert !res.output.contains('Banana')
	assert res.output.contains('cherry')
	assert res.output.contains('Apple pie')
	test_cleanup()
}

// Literal pattern should still support -o (only-matching). This verifies
// the match caching path works correctly for only-matching mode.
fn test_literal_pattern_only_matching() {
	test_setup()
	res := os.execute('${exe_path} --color=never -o "Banana|cherry" ${os.join_path(test_root, "data.txt")}')
	assert res.exit_code == 0
	assert res.output.contains('Banana')
	assert res.output.contains('cherry')
	assert !res.output.contains('apple')
	assert !res.output.contains('Apple')
	test_cleanup()
}

// Literal detection should NOT activate when the pattern contains real
// regex meta-chars like []. The regex engine path must still work.
fn test_literal_detection_not_triggered_by_regex() {
	test_setup()
	res := os.execute('${exe_path} --color=never "[Bb]anana" ${os.join_path(test_root, "data.txt")}')
	assert res.exit_code == 0
	assert res.output.contains('Banana')
	test_cleanup()
}

// -F (explicit fixed-string) should still work even when the pattern
// technically contains regex meta-chars — because -F ignores them.
fn test_explicit_fixed_strings_bypasses_literal_check() {
	test_setup()
	res := os.execute('${exe_path} --color=never -F "^apple" ${os.join_path(test_root, "data.txt")}')
	// "^apple" literally, not as a regex anchor
	assert res.exit_code == 1
	test_cleanup()
}
