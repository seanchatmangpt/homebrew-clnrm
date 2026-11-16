# homebrew-clnrm: push or delete local-only branch `exp/offline-formula-audit`

- Standing: OPEN
- Created: 2026-09-19 (v26.9.19 gh survey wave)
- Source: local branch `exp/offline-formula-audit` has 1 commit(s) not on `origin/master`, no upstream
- Evidence: `git rev-list --count origin/master..exp/offline-formula-audit` = 1

## Work to complete
- Push (`git push -u origin exp/offline-formula-audit`) if the work matters; otherwise delete the branch after confirming the commits are obsolete.

## Acceptance
- Branch pushed and visible on GitHub, or deleted locally with commits confirmed recoverable-or-unwanted.

## History
- 2026-09-19 | OPEN | survey found local-only branch | exp/offline-formula-audit (1 commits) | decision pending
