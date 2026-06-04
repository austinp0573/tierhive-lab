# scripts

The script runner is split by intent:

- `setup.sh` runs the numbered scripts in `core/`.
- `run-scripts.sh` offers setup extras from `optional/`.
- `run-diagnostics.sh` offers non-setup checks from `diagnostics/`.
- `alternates/` contains manual alternate paths that should not be offered after core setup.
- `lib/` contains small shared shell helpers.

`core/` is ordered by filename. Keep the numbers spaced out so new steps can be inserted later.

Dropbear is the default minimal path. If you want to keep OpenSSH, use `alternates/minimal-openssh.sh` instead of the default Dropbear core step.
