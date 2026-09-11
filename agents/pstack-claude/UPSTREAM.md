# Vendored pstack-claude

This tree is a **pristine, byte-identical** copy of upstream, vendored so this repo is the single
source of truth for pstack across claude, codex, and pi. Do not patch files here — send fixes
upstream or keep them in a separate overlay.

- Source: https://github.com/michael-denyer/pstack-claude
- Pinned commit: `c42e947d417f9e3f10bc59d54b05be744737f4f2`
- Version: 0.9.13
- Vendored: 2026-09-10

## Updating

```sh
git clone --depth 1 --branch <tag> https://github.com/michael-denyer/pstack-claude.git /tmp/pstack
rsync -a --delete --exclude=.git /tmp/pstack/ agents/pstack-claude/
```

1. Edit this file (new commit / version / date), review `CHANGES.md`, commit.
2. Refresh derived caches:
   - Claude: `claude plugin update pstack@pstack-claude`
   - Codex: `codex plugin remove pstack && codex plugin add pstack@pstack-claude` (if it caches)
   - Pi: nothing — the skills symlink is live immediately.
