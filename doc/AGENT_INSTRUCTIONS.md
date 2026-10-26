# Instructions for AI Agents Working in This Repository

Standing rules to follow when inspecting files in this project.

## 1. Check file size before reading

Before reading any file, first check its size and line count, e.g.:

    ls -l <file>
    wc -l <file>

Do not assume a file's contents based on a read attempt alone.

## 2. Choose the read strategy based on size

- **Small files** (≲ 100 KB, or ≲ a few thousand lines): read in full.
- **Large files** (e.g. logs, traces, execution files): do NOT attempt a
  full read. Instead use targeted commands:
  - `tail -n 100 <file>` — to check the end (final status of a run)
  - `head -n 50 <file>` — to check the beginning
  - `grep -n <pattern> <file>` — to find errors/warnings
  - For Nextflow logs specifically, the end of `nextflow.out` and `nextflow.err`  are the fastest way to
    assess whether a run succeeded.

## 3. Never conclude a file is empty from a failed or empty read

An empty or failed tool result is NOT evidence that the file is empty.
Always cross-verify with an independent method (`wc -l`, `ls -l`,
`tail -n 1`) before stating that a file contains no data.

### Background (2026-10-24)

While summarising the nfcore/rnaseq run, `nextflow.out` (35,024 lines)
was reported as empty because the read tool silently failed on the large
file, and the empty result was taken at face value. These rules exist
to prevent that from recurring.
