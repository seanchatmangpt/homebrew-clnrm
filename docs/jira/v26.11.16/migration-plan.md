# homebrew-clnrm migration plan v26.11.16

Standing: UNVERIFIED

## Identity
- Path: /Users/sac/homebrew-clnrm
- Remote: https://github.com/seanchatmangpt/homebrew-clnrm.git
- Branch: master@9dd1489 (upstream origin/master, ahead 2)
- Last commit: 2026-09-16 ("Merge exp/offline-formula-audit: offline formula audit + tests")
- Commits: 9; size: ~0 MB
- Languages/build: Homebrew tap (Formula/, lib/, script/, test/), shell; no CLAUDE.md
- Nested repos: none

## Observed state
- Dirty: 0, untracked: `docs/` (3 files: docs/jira/v26.9.19 catalogue docs).
- Ahead 2 / behind 0 — the audit merge is unpushed.
- Unpushed local branch: `exp/offline-formula-audit` (already merged into master).
- Stash: 0. Build dirs: none. Submodules: none.

## What it is
Homebrew tap for the Cleanroom Testing Framework (`brew tap seanchatmangpt/clnrm`), plus an
offline formula audit script and tests.

## Classification
WARM (census agrees).

## Migration risk
- 2 unpushed commits on master and the untracked docs/ dir.
Rating: MEDIUM (small but unpushed).

## Recommended action
COMMIT-PUSH

1. `git add docs && git commit -m "docs: jira catalogue v26.9.19 + v26.11.16"`.
2. `git push origin master`.
3. DECISION: delete merged `exp/offline-formula-audit` or push it
   (`git push origin exp/offline-formula-audit`).
4. New machine: clone fresh.

## First commands on the new machine
`brew tap seanchatmangpt/clnrm && brew audit --strict clnrm` and `bash script/<audit script>`.
Stated, not run.

## See Also
- ../v26.9.19/
- /Users/sac/docs/jira/v26.11.16/README.md
