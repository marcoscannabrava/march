# Fork of pstack

- Upstream: https://github.com/michael-denyer/pstack-claude
- Forked commit: `c42e947d417f9e3f10bc59d54b05be744737f4f2`
- Version: 0.9.13
- Date: 2026-09-10

## Updating

```sh
git clone --depth 1 --branch <tag> https://github.com/michael-denyer/pstack-claude.git /tmp/pstack
rsync -a --delete --exclude=.git /tmp/pstack/ agents/pstack-claude/
```

1. Edit this file (new commit / version / date), commit.
2. Refresh derived caches:
   - Claude: `claude plugin update pstack@pstack-claude`
   - Codex: `codex plugin remove pstack@pstack-claude && codex plugin add pstack@pstack-claude`
   - Pi: nothing — the skills symlink is live immediately.
