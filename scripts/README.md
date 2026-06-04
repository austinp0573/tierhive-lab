# scripts

the script runner is split by intent:

- `setup.sh` runs the numbered scripts in `core/` in order, then optionally offers `optional/`.
- `run-scripts.sh` offers setup extras from `optional/` on its own.
- `run-diagnostics.sh` offers non-setup checks from `diagnostics/`.
- `alternates/` contains manual alternate paths that should not be offered after core setup.
- `lib/` contains small shared shell helpers.
- `legacy/` contains the old standalone scripts, kept for reference only.

`core/` is ordered by filename. keep the numbers spaced out so new steps can be inserted later.

dropbear is the default minimal path. if you want to keep openssh, run `alternates/minimal-openssh.sh`
manually before or instead of running core setup.

python removal is part of the default minimal path. if this host is managed by ansible or needs
python for any reason, edit `lib/alpine-minimal-base.sh` and remove the python packages from the
`apk del` call in section 2.
