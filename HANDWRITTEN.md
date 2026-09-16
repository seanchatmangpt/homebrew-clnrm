# Handwritten ledger (UNSUPPORTED admissions)

Per the DfCM contract, these product-surface bytes are hand-written because no
admitted pack/generator expresses their semantic element (search ladder run
2026-09-16: no brew/tap/formula capability family in ggen-marketplace/packs or
ggen_igniter priv/ggen). Every row is debt with an owner-pack paydown plan;
this ledger shrinks monotonically per milestone.

path | semantic element | missing capability | intended owner pack | date
--- | --- | --- | --- | ---
lib/tap_audit.rb, script/audit | offline brew-audit-style formula validation (ruby syntax, stable https url, sha256 shape, version/tag consistency, class/file-name convention) | no admitted pack renders a ruby offline-audit CLI for tap formulas | tap-audit (candidate; to be admitted via marketplace admission) | 2026-09-16
test/audit_test.rb | minitest suite exercising the audit (unit per check + CLI end-to-end, green and red paths) | same | tap-audit | 2026-09-16

Paydown plan: admit `tap-audit` (pack.toml + SemVer + description + RDF source
+ gates + templates rendering lib/script/test from the formula checks encoded
as pack facts); when the projection reconciles against these files, delete the
rows above.
