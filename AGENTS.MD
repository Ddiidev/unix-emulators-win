# Unix Executable Emulators for Windows

This directory contains implementations of standard UNIX utilities written in the [V programming language](https://vlang.io/).

## Purpose
The primary purpose is to provide these executables for tools that rely on UNIX shell syntax or commands, specifically **rtk (AI proxy)**. Because Windows lacks native commands like `ls`, and aliases or PowerShell emulations are often insufficient for external programs calling standard executables, these standalone binaries bridge that gap.

## Structure
By convention, each executable's source code is placed in its own folder named `exe_<command>` (e.g., `exe_ls`). 
Each folder contains an integration test suite in the `tests/` directory, which can be run with `v test tests/`.

## Testing Policy
- **New features and optimizations** MUST include at least one integration test that validates the new behavior. Create a new `tests/<feature>_test.v` file following the existing naming and `os.execute`-based pattern.
- **Changes to existing behavior or internal flows** MUST add or update tests to cover the modified code path. If the change alters how something already worked, update the relevant existing test file rather than creating a new one.
- Tests are black-box integration tests: compile the binary with `v -prod`, then call it via `os.execute()` and assert exit codes and stdout content.
- Run `v test tests/` in the executable's source directory after every change to confirm nothing is broken.

## Deployment
Binaries are compiled and installed into `c:\Users\andre\bin\`, which should be added to the Windows `PATH`.

## List of implemented executables (16 tools)
All tools return POSIX-compliant exit codes and are verified via integration tests.

### Argument Policy
For any argument that is not yet implemented, the tools return a standardized error message in English to inform the user (or AI agent) that the flag is unsupported:
`TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED. USE AN ALTERNATIVE METHOD, AS THE "ls" COMMAND DOES NOT YET HAVE THIS ARGUMENT "-la".`

- `ls` (implemented in `exe_ls`) - Comprehensive GNU/UNIX compatible version. Supports `-a`, `-l`, `-h`, `-R`, `-S`, `-t`, `-v` (natural sort), `-F`, `-1`, `-m`, `-d`, `--color`, `--group-directories-first`, and many more.
- `cat` (implemented in `exe_cat`) - Supports numbering (`-n`, `-b`), squeezing (`-s`), show-ends (`-E`), show-tabs (`-T`), and `-A` (show-all).
- `grep` (implemented in `exe_grep`) - Regex search with colors, recursion (`-r`/`-R`), context (`-A`/`-B`/`-C`), fixed strings (`-F`), only-matching (`-o`), max-count (`-m`), `--include`/`--exclude`/`--exclude-dir`, and `-L` (files-without-match).
- `rm` (implemented in `exe_rm`) - Recursive (`-r`), force (`-f`), interactive (`-i`), verbose (`-v`), and empty-dir (`-d`) removal.
- `mkdir` (implemented in `exe_mkdir`) - Supports parent directory creation (`-p`) and verbose (`-v`).
- `touch` (implemented in `exe_touch`) - Creates files, updates timestamps, supports `-c` (no-create), `-a` (access-time only), `-m` (modification-time only).
- `cp` (implemented in `exe_cp`) - Recursive copy (`-r`), interactive (`-i`), force (`-f`), no-clobber (`-n`), and verbose (`-v`).
- `mv` (implemented in `exe_mv`) - File moving/renaming with `-f`, `-i`, `-n` (no-clobber), and `-v`.
- `find` (implemented in `exe_find`) - Search for files with `-name`, `-iname`, `-type`, `-empty`, `-maxdepth`, `-delete`, and `-o` (OR logic). Regex patterns are pre-compiled for performance.
- `pwd` (implemented in `exe_pwd`) - Print current working directory with forward-slash paths.
- `which` (implemented in `exe_which`) - Locate a command on PATH, supports `-a` (all matches). Respects PATHEXT on Windows.
- `head` (implemented in `exe_head`) - Output first part of files with `-n` (lines), `-c` (bytes), `-v`/`-q` (headers).
- `tail` (implemented in `exe_tail`) - Output last part of files with `-n`, `-f` (follow), `-s` (sleep interval), `-v`/`-q`. Uses seek-from-end for large file support.
- `sort` (implemented in `exe_sort`) - Sort lines with `-r` (reverse), `-n` (numeric), `-u` (unique).
- `uniq` (implemented in `exe_uniq`) - Filter adjacent duplicates with `-c` (count), `-d` (repeated), `-u` (unique), `-i` (ignore-case).
- `xargs` (implemented in `exe_xargs`) - Build commands from stdin with `-0` (NUL separator), `-I` (replace string), `-n` (max args), `-t` (verbose), `-r` (no-run-if-empty).
