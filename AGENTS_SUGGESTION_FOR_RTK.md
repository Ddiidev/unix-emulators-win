# Agent System Prompt Suggestion for RTK on Windows

Include this in your agent's system prompt to force efficient use of these UNIX emulator tools through [rtk](https://github.com/rtk-ai/rtk/).

## The Prompt

```
## RTK on Windows
**MANDATORY**: Use `rtk` wrappers for CLI operations on Windows.
**FORBIDDEN**: Do not use native PowerShell cmdlets for file/text operations (`Select-String`, `Get-Content`, `Get-ChildItem`, `sls`, `gc`, `gci`). Use `rtk grep`, `rtk cat`, `rtk ls`, `rtk findd`, etc.

- Start with `rtk`; if it fails, retry with another `rtk` approach first.
- The next command starts with `rtk` again. Fall back to native Windows only when `rtk` keeps failing for that specific case.
- If the user says "no rtk", do not use it.
- Prefer short Unix-style pipelines with `rtk`, e.g. `rtk grep ... | rtk head ...`.
- Use `findd` under `rtk` on Windows-unix-like environments.
- Prefer targeted paths/extensions over broad recursive scans from `.`.
- Prefer `findd | xargs grep` when it can narrow by directory and file type before running `grep`.
- Do not read, grep, cat, or recurse into binary files unless explicitly asked.
- Treat `.dll`, `.so`, `.exe`, `.sqlite`, `.db`, `.bin`, `.png`, `.jpg`, `.jpeg`, `.gif`, `.webp`, `.pdf`, `.zip`, `.woff`, `.woff2`, `.ttf`, and similar files as binary by default.
- For recursive `grep`, always use `--exclude-dir` for dependency/build/cache/generated/VCS folders: `.git`, `node_modules`, `bin`, `obj`, `dist`, `build`, `out`, `coverage`, `.next`, `.nuxt`, `.svelte-kit`, `.vite`, `target`, `vendor`, `.cache`, `tmp`, `temp`, `logs`, `.venv`, `venv`, `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.gradle`.
- For recursive `grep`, always use `--exclude` for binary/large generated extensions: `*.dll`, `*.so`, `*.exe`, `*.sqlite`, `*.db`, `*.bin`, `*.png`, `*.jpg`, `*.jpeg`, `*.gif`, `*.webp`, `*.pdf`, `*.zip`, `*.woff`, `*.woff2`, `*.ttf`.

Examples:
- `rtk git status --short --branch`
- `rtk git diff --stat`
- `rtk ls -la`
- `rtk grep -n "pattern" path`
- `rtk cat path/to/file`
- `rtk findd . -iname AGENTS.md -o -iname "*_AGENTS.md" -o -iname "AGENTS_*.md"`
- `rtk findd repository entities -name "*.v" | xargs grep -E "pattern" | head -n 200`
- `rtk grep -RniE "pattern1|pattern2" . --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=bin --exclude-dir=obj --exclude-dir=dist --exclude-dir=build --exclude=*.dll --exclude=*.so --exclude=*.exe --exclude=*.sqlite --exclude=*.db --exclude=*.bin | rtk head -n 200`
```

## Why This Matters

PowerShell cmdlets produce verbose, object-formatted output that wastes thousands of AI tokens per call. These UNIX-style tools output dense plain text — a single `rtk grep ... | rtk head -n 80` can replace a 200-line PowerShell output with 3-5 lines the LLM can consume instantly. That's tokens you don't pay for.
