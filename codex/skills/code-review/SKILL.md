---
name: code-review
description: Comprehensive review of recently changed code. Use when the user asks for a review, PR feedback, a pre-merge check, a regression scan, or a second opinion on modified files, a diff, a branch, or a commit. Focus on bugs, behavioral regressions, security issues, maintainability risks, reviewability problems, and missing tests in the changed code rather than unrelated legacy debt.
---

# Code Review

Provide a pragmatic, findings-first review of changed code. Treat review as risk triage, not as line-by-line commentary.

## Establish Scope

Start by determining what changed.

- Prefer the explicit scope the user provided.
- Otherwise inspect the current diff or recent changes with the repo's normal VCS workflow.
- Focus on changed files and the surrounding code needed to understand them.
- Call out any assumptions when the scope is ambiguous.

Do not spend the review on untouched legacy code unless the change clearly depends on it.

## Build Context

Before judging the change:

- Read nearby implementation and tests.
- Read repo guidance such as `AGENTS.md`, style guides, or local conventions that apply to the changed paths.
- Understand the intended behavior before critiquing the implementation.

If important context is missing, say so and reduce confidence accordingly.

## Analyze Systematically

Check the changed code for issues in these areas:

1. Correctness and regressions
2. Security, auth, validation, and data exposure
3. Concurrency, transactions, caching, and state handling
4. Maintainability, complexity, and pattern fit with the codebase
5. Dead code, redundant logic, or accidental over-engineering
6. Documentation drift when behavior, configuration, or interfaces changed
7. Test coverage for critical paths, edge cases, and failure modes
8. Reviewability problems such as mixed concerns or changes that are harder to verify than necessary

Report only issues that are real and actionable. Skip low-signal style comments unless they hide a bug or create ongoing cost.

## Prioritize Findings

Order findings by severity:

- Critical: security vulnerabilities, data loss, or clear production breakage
- High: likely bugs, contract mismatches, or serious reliability risks
- Medium: maintainability or correctness risks worth fixing soon
- Low: smaller issues that are still worth noting

When in doubt, lower the severity and explain the uncertainty.

## Output Contract

Present findings first. Keep summaries brief.

For each finding include:

- Severity
- Short title
- Exact location when available
- Why it matters
- Concrete fix direction

Use file and line references whenever possible.

If there are no findings, say that explicitly and mention any residual risks or testing gaps.

After findings, optionally include:

- Open questions or assumptions that could change the review
- A very short change summary

## Review Style

- Be direct, respectful, and specific.
- Explain the reasoning behind each finding.
- Offer practical fixes, not vague preferences.
- Avoid demanding large rewrites unless simpler options are inadequate.
- Do not manufacture issues to fill space.

## Final Check

Before finishing, verify:

- The review stayed focused on the changed code
- The reported findings are supported by evidence
- The most serious bug or security risks were not missed
- Missing tests or stale docs were called out when relevant
- The final response is ordered by severity and easy to act on
