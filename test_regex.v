import regex

fn main() {
	mut re := regex.regex_opt('^.*\\.txt$') or { panic(err) }
	println('match file.txt: ${re.matches_string("file.txt")}')
	println('match file.log: ${re.matches_string("file.log")}')
}
