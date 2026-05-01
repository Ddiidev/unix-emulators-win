# 🛠️ Unix Executable Emulators for Windows

> **16 standalone UNIX utilities** written in [V](https://vlang.io/) — bridging the gap between Windows and UNIX shell environments for AI agents and developer tools.
>
> 🇧🇷 [Leia em português](README.pt-br.md)

![Tools](https://img.shields.io/badge/tools-16-blue)
![Language](https://img.shields.io/badge/language-V-5D87BF)
![Platform](https://img.shields.io/badge/platform-Windows-0078D6)
![Tests](https://img.shields.io/badge/tests-55+-green)

---

## Table of Contents

- [Why This Exists](#why-this-exists)
- [Quick Start](#quick-start)
- [Tool Reference](#tool-reference)
  - [File Listing & Inspection](#file-listing--inspection)
  - [File Content](#file-content)
  - [Search & Filter](#search--filter)
  - [File Operations](#file-operations)
  - [Utilities](#utilities)
- [Argument Policy](#argument-policy)
- [Testing](#testing)
- [Architecture](#architecture)
- [Building](#building)

---

## Why This Exists

Windows lacks native equivalents of standard UNIX commands (`ls`, `grep`, `find`, etc.). While PowerShell provides aliases, they are incompatible with external programs that expect real executables on `PATH`. This project provides **standalone `.exe` binaries** that:

1. **Work as real executables** — callable from any shell, script, or external tool (e.g., `rtk`, AI agents like Codex/Gemini)
2. **Return POSIX exit codes** — `0` for success, `1` for no match/error, `2` for usage errors
3. **Support common GNU/UNIX flags** — progressively implementing the most-used flags
4. **Handle Windows paths** — backslash/forward-slash normalization, `PATHEXT` support

---

## Quick Start

### Prerequisites
- [V compiler](https://vlang.io/) installed and on PATH

### Build All
```powershell
cd executables
.\build.bat
# or
powershell -File .\build.ps1
```

### Build Single Tool
```powershell
cd executables\exe_ls
.\build.bat
```

Binaries are installed to `c:\Users\andre\bin\`, which should be on your `PATH`.

### First Usage
```powershell
ls -la .
grep -rn "TODO" ./src --include="*.v"
find . -iname "*.txt" -type f
cat -n file.txt | head -n 20
sort data.csv | uniq -c
```

---

## Tool Reference

### File Listing & Inspection

#### `ls` — List directory contents
```
ls [OPTIONS] [FILE...]
```

| Flag | Description |
|------|-------------|
| `-a`, `--all` | Show hidden files (starting with `.`) |
| `-A`, `--almost-all` | Like `-a` but exclude `.` and `..` |
| `-l`, `--long` | Long listing format with permissions, size, date |
| `-h`, `--human-readable` | Human-readable sizes (1K, 234M, 2G) with `-l` |
| `--si` | Like `-h` but use powers of 1000 |
| `-r`, `--reverse` | Reverse sort order |
| `-R`, `--recursive` | List subdirectories recursively |
| `-1`, `--one-line` | One file per line |
| `-m`, `--commas` | Comma-separated list |
| `-S` | Sort by file size (largest first) |
| `-t` | Sort by modification time (newest first) |
| `-v` | Natural sort of version numbers (`file2` before `file10`) |
| `-X` | Sort alphabetically by extension |
| `-U` | Do not sort (directory order) |
| `-F`, `--classify` | Append indicator (`*/=>@|`) to entries |
| `-p`, `--slash` | Append `/` to directories |
| `--group-directories-first` | Group directories before files |
| `-i`, `--inode` | Print inode number |
| `-s`, `--size` | Print allocated size in blocks |
| `-n`, `--numeric-uid-gid` | Numeric user/group IDs |
| `-g`, `--no-owner` | Like `-l` but hide owner |
| `-G`, `--no-group` | Hide group in long listing |
| `-o` | Like `-l` but hide group |
| `-d`, `--directory` | List directories themselves, not contents |
| `-Q`, `--quote-name` | Enclose names in double quotes |
| `-b`, `--escape` | C-style escapes for non-graphic characters |
| `--color=WHEN` | Colorize output (`always`, `auto`, `never`) |
| `--time-style=STYLE` | Time format (`full-iso`, `long-iso`, `iso`, `locale`) |
| `--full-time` | Like `-l --time-style=full-iso` |
| `-u` | Sort/show access time |
| `-c` | Sort/show status change time |

---

#### `pwd` — Print working directory
```
pwd [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-L` | Use PWD from environment (default) |
| `-P` | Resolve all symlinks (stub) |

Outputs forward-slash paths for UNIX compatibility.

---

#### `which` — Locate a command
```
which [OPTIONS] COMMAND...
```

| Flag | Description |
|------|-------------|
| `-a`, `--all` | Print all matching pathnames |

Searches `PATH` directories and respects `PATHEXT` on Windows.

---

### File Content

#### `cat` — Concatenate and display files
```
cat [OPTIONS] [FILE...]
```

| Flag | Description |
|------|-------------|
| `-n`, `--number` | Number all output lines |
| `-b`, `--number-nonblank` | Number non-empty lines only (overrides `-n`) |
| `-s`, `--squeeze-blank` | Suppress repeated empty lines |
| `-E`, `--show-ends` | Display `$` at end of each line |
| `-T`, `--show-tabs` | Display TAB as `^I` |
| `-A`, `--show-all` | Equivalent to `-vET` |

Reads from stdin when no file is specified or file is `-`.

---

#### `head` — Output first part of files
```
head [OPTIONS] [FILE...]
```

| Flag | Description |
|------|-------------|
| `-n K`, `--lines=K` | Print first K lines (default: 10) |
| `-c K`, `--bytes=K` | Print first K bytes |
| `-v`, `--verbose` | Always print file name headers |
| `-q`, `--quiet` | Never print file name headers |

---

#### `tail` — Output last part of files
```
tail [OPTIONS] [FILE...]
```

| Flag | Description |
|------|-------------|
| `-n K`, `--lines=K` | Output last K lines (default: 10) |
| `-f`, `--follow` | Output appended data as file grows |
| `-s N`, `--sleep-interval=N` | Sleep N seconds between follow iterations |
| `-v`, `--verbose` | Always print file name headers |
| `-q`, `--quiet` | Never print file name headers |

> **Performance**: Uses seek-from-end approach — handles multi-GB files without loading them into memory.

---

### Search & Filter

#### `grep` — Search for patterns in files
```
grep [OPTIONS] PATTERN [FILE...]
```

| Flag | Description |
|------|-------------|
| `-i`, `--ignore-case` | Case-insensitive matching |
| `-v`, `--invert-match` | Select non-matching lines |
| `-n`, `--line-number` | Print line numbers |
| `-c`, `--count` | Print only match count per file |
| `-l`, `--files-with-matches` | Print only filenames with matches |
| `-L`, `--files-without-matches` | Print only filenames without matches |
| `-r`, `-R`, `--recursive` | Search directories recursively |
| `-w`, `--word-regexp` | Match whole words only |
| `-x`, `--line-regexp` | Match whole lines only |
| `-F`, `--fixed-strings` | Treat pattern as literal string |
| `-o`, `--only-matching` | Show only the matched part of lines |
| `-H`, `--with-filename` | Print filename with output |
| `-h`, `--no-filename` | Suppress filename prefix |
| `-A N`, `--after-context=N` | Print N lines after each match |
| `-B N`, `--before-context=N` | Print N lines before each match |
| `-C N`, `--context=N` | Print N lines of context (before + after) |
| `-m N`, `--max-count=N` | Stop after N matches per file |
| `-q`, `--quiet` | Suppress all output |
| `-s`, `--silent` | Suppress error messages |
| `--color=WHEN` | Colorize matches (`always`, `auto`, `never`) |
| `--exclude=GLOB` | Skip files matching GLOB |
| `--exclude-dir=DIR` | Skip directories matching DIR |
| `--include=GLOB` | Search only files matching GLOB |

> **Performance**: Auto-detects literal patterns to bypass the regex engine, circular buffer for context lines (O(1) vs O(n) for before-context), auto-excludes `node_modules`/`.git`/`vendor`/etc in recursive scans, iterative BFS-based directory traversal.

---

#### `find` — Search for files in directory hierarchy
```
find [PATH...] [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-name PATTERN` | Match filename (case-sensitive glob) |
| `-iname PATTERN` | Match filename (case-insensitive glob) |
| `-type TYPE` | Filter by type (`f` = file, `d` = directory) |
| `-empty` | Match empty files/directories |
| `-maxdepth N` | Descend at most N levels |
| `-delete` | Delete matched files |
| `-o`, `-or` | OR operator between filter groups |

Supports combining multiple filters with `-o` (OR logic). Glob patterns use `*` and `?`.

> **Performance**: Regex patterns are pre-compiled once at startup, not per-file.

---

#### `sort` — Sort lines of text files
```
sort [OPTIONS] [FILE...]
```

| Flag | Description |
|------|-------------|
| `-r`, `--reverse` | Reverse sort order |
| `-n`, `--numeric-sort` | Compare by numerical value |
| `-u`, `--unique` | Output only unique lines |

---

#### `uniq` — Filter adjacent duplicate lines
```
uniq [OPTIONS] [INPUT [OUTPUT]]
```

| Flag | Description |
|------|-------------|
| `-c`, `--count` | Prefix lines by occurrence count |
| `-d`, `--repeated` | Only print duplicate lines |
| `-u`, `--unique` | Only print unique lines |
| `-i`, `--ignore-case` | Case-insensitive comparison |

---

### File Operations

#### `cp` — Copy files and directories
```
cp [OPTIONS] SOURCE... DEST
```

| Flag | Description |
|------|-------------|
| `-r`, `-R`, `--recursive` | Copy directories recursively |
| `-f`, `--force` | Force overwrite |
| `-i`, `--interactive` | Prompt before overwrite |
| `-n`, `--no-clobber` | Do not overwrite existing files |
| `-v`, `--verbose` | Explain what is being done |

---

#### `mv` — Move/rename files
```
mv [OPTIONS] SOURCE... DEST
```

| Flag | Description |
|------|-------------|
| `-f`, `--force` | Do not prompt before overwriting |
| `-i`, `--interactive` | Prompt before overwrite |
| `-n`, `--no-clobber` | Do not overwrite existing files |
| `-v`, `--verbose` | Explain what is being done |

---

#### `rm` — Remove files and directories
```
rm [OPTIONS] FILE...
```

| Flag | Description |
|------|-------------|
| `-r`, `-R`, `--recursive` | Remove directories recursively |
| `-f`, `--force` | Ignore nonexistent files, never prompt |
| `-i`, `--interactive` | Prompt before every removal |
| `-v`, `--verbose` | Explain what is being done |
| `-d`, `--dir` | Remove empty directories |

---

#### `mkdir` — Create directories
```
mkdir [OPTIONS] DIRECTORY...
```

| Flag | Description |
|------|-------------|
| `-p`, `--parents` | Create parent directories as needed |
| `-v`, `--verbose` | Print message for each created directory |

---

#### `touch` — Update file timestamps
```
touch [OPTIONS] FILE...
```

| Flag | Description |
|------|-------------|
| `-c`, `--no-create` | Do not create any files |
| `-a` | Change only the access time |
| `-m` | Change only the modification time |

---

### Utilities

#### `xargs` — Build and execute commands from stdin
```
xargs [OPTIONS] [COMMAND [ARGS...]]
```

| Flag | Description |
|------|-------------|
| `-0`, `--null` | Input items separated by NUL (for `find -print0`) |
| `-I REPLACE` | Replace REPLACE in args with each input item |
| `-n MAX` | Use at most MAX arguments per command |
| `-t`, `--verbose` | Print commands before execution |
| `-r`, `--no-run-if-empty` | Don't run command if stdin is empty |

**Examples:**
```bash
find . -name "*.txt" | xargs grep "TODO"
find . -print0 | xargs -0 wc -l
echo file1 file2 | xargs -I {} cp {} /backup/
ls *.log | xargs -n 2 echo "Batch:"
```

---

## Argument Policy

For any flag that is **not yet implemented**, the tools return a standardized error message:

```
TODO (UNIX WINDOWS): THIS ARGUMENT HAS NOT YET BEEN IMPLEMENTED.
USE AN ALTERNATIVE METHOD, AS THE "ls" COMMAND DOES NOT YET HAVE THIS ARGUMENT "-la".
```

This message is designed for AI agents to understand and use alternative approaches.

---

## Testing

Each tool has integration tests in its `tests/` directory:

```powershell
# Run tests for a specific tool
cd executables\exe_grep
v test tests/

# Run all tests
Get-ChildItem -Directory exe_* | ForEach-Object {
    Write-Host "Testing $($_.Name)..."
    Push-Location $_.FullName
    v test tests/
    Pop-Location
}
```

Tests use `os.execute()` to run the compiled binary and verify exit codes and output. New features and optimizations require new tests — see [AGENTS.md](AGENTS.MD) for the full testing policy.

---

## Architecture

```
executables/
├── AGENTS.MD          # Agent-facing documentation & testing policy
├── README.md          # This file
├── README.pt-br.md    # Brazilian Portuguese version
├── build.ps1          # Build all tools
├── build.bat          # Wrapper for build.ps1
├── exe_ls/            # Each tool in its own directory
│   ├── main.v         # Entry point & argument parsing
│   ├── lister.v       # Core logic (directory listing)
│   ├── filedata.v     # Data structures
│   ├── options.v      # Options struct
│   ├── utils.v        # Utility functions
│   ├── build.bat      # Individual build script
│   └── tests/
│       └── ls_test.v  # Integration tests
├── exe_grep/
│   ├── main.v
│   ├── matcher.v      # Regex/fixed-string matching engine
│   ├── processor.v    # File processing & output
│   ├── filters.v      # --exclude/--include handling
│   ├── options.v
│   └── tests/
│       ├── grep_test.v
│       ├── context_test.v
│       ├── exclude_test.v
│       ├── literal_test.v
│       └── autoexclude_test.v
└── ...                # 14 more tools following the same pattern
```

### Conventions

- **Directory naming**: `exe_<command>` (e.g., `exe_ls`, `exe_grep`)
- **Build output**: Each `build.bat` compiles to `../../<command>.exe` (the `bin/` root)
- **Build flags**: All builds use `-prod` for optimized release binaries
- **Module**: All files use `module main`
- **Options**: Parsed with V's `flag` module, stored in an `Options` struct

---

## Building

### Single Tool
```powershell
cd executables\exe_ls
v -prod -o "..\..\ls.exe" .
```

### All Tools
```powershell
cd executables
.\build.ps1
```

### Development (fast, no optimizations)
```powershell
cd executables\exe_ls
v -o "..\..\ls.exe" .
```

---

## License

Internal tooling — part of the `rtk` ecosystem.
