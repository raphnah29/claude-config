# Global preferences

- Reply in English, concise.
- I mainly write C/C++. Follow the nearest `.clang-format` (Google-based) and run `clang-format -i` on files you edit.
- Prefer CMake: configure/build in `build/` (`cmake -B build && cmake --build build`), then `ctest --test-dir build`.
- Never commit or push unless I ask.
- Git commits: one-line message only (no body), and no Co-Authored-By / Claude attribution.

## Two environments: Linux + macOS
I work on both a Linux PC and a Mac. Everything you write (code, scripts, build files, commands) must work on both.
- Prefer portable choices:
  - POSIX shell, or bash 3.2–compatible (the macOS default): no `declare -A`, `mapfile`, `${var,,}`.
  - Avoid GNU-only flags: `sed -i` (use `sed -i.bak`, or a temp file), `readlink -f`, `date -d`, `grep -P`, `find -printf`.
  - Use `$HOME`/`~`, never `/home/raphael` or `/Users/raphael`.
- C/C++:
  - Write CMake that works with GCC (Linux) and Apple Clang (macOS).
  - Don't hardcode `-lrt`, `-static`, or Linux-only headers/APIs (`epoll`, `<sys/sysinfo.h>`, `/proc`) without a guarded alternative.
  - Keep `#ifdef __APPLE__` / `__linux__` branches small and isolated.
- Package installs: give both `brew` and `apt` commands.
- If something can't be portable, or you're unsure, **warn me explicitly**: "⚠ Won't work on macOS/Linux because …", with the workaround, before or alongside the change. Never stay silent about it.
