#! /bin/zsh

# Create short-lived workspace layouts from named strategies.
# Usage: hoist <strategy> [target]
function hoist() {
  local strategy="${1:-help}"
  [[ $# -gt 0 ]] && shift

  case "$strategy" in
    help|-h|--help)
      cat <<'EOF'
Usage: hoist <strategy> [target]

Strategies:
  worktree-hub  Create a categorized Git worktree hub

Commands:
  list          List available strategies
  help          Show this help

The target defaults to the current directory.
EOF
      ;;
    list)
      if [[ $# -ne 0 ]]; then
        echo "Usage: hoist list" >&2
        return 1
      fi
      printf '%-14s %s\n' "worktree-hub" "categorized Git worktree hub"
      ;;
    worktree-hub)
      if [[ $# -gt 1 ]]; then
        echo "Usage: hoist worktree-hub [target]" >&2
        return 1
      fi

      local target="${1:-.}"
      local -a directories=(auxiliary bug-fixes documentation features local)
      local directory entry_path

      if [[ (-e "$target" || -L "$target") && ! -d "$target" ]]; then
        echo "Error: Target is not a directory: $target" >&2
        return 1
      fi

      for directory in $directories; do
        entry_path="$target/$directory"
        if [[ (-e "$entry_path" || -L "$entry_path") && ! -d "$entry_path" ]]; then
          echo "Error: Expected a directory but found another entry: $entry_path" >&2
          return 1
        fi
      done

      for entry_path in "$target/AGENTS.md" "$target/documentation/AGENTS.md"; do
        if [[ -d "$entry_path" && ! -L "$entry_path" ]]; then
          echo "Error: Expected a file but found a directory: $entry_path" >&2
          return 1
        fi
      done

      mkdir -p "$target" || return 1
      for directory in $directories; do
        mkdir -p "$target/$directory" || return 1
      done

      if [[ ! -e "$target/AGENTS.md" && ! -L "$target/AGENTS.md" ]]; then
        cat > "$target/AGENTS.md" <<'EOF'
# Repository Hub Instructions

This directory is a Git worktree hub, not an application workspace. Select a worktree before changing application code, then follow that worktree's own `AGENTS.md`. Nested `AGENTS.md` files override broader instructions for their subtree.

## Worktree Layout

- `main/` — primary checkout for the main development branch.
- `features/<id>-<slug>/` — feature worktrees.
- `bug-fixes/<id>-<slug>/` — hotfix worktrees.

Each worktree is a complete repository checkout with its own files, tooling, and instructions.

## Hub Directories

These directories belong to the hub, not to any individual worktree.

- `._repo/` — bare Git repository and worktree metadata. Never edit manually.
- `auxiliary/` — hub-level examples and supporting assets that are not feature documentation.
- `documentation/` — hub-level documentation such as planning, research, rollout notes, test matrices, or project-independent documentation shared across worktrees.
- `local/` — local-only configuration, credentials, and machine-specific files. Treat as sensitive. Never copy values into tracked files or responses.

## Working Inside a Worktree

Once a worktree has been selected:

1. Change into the worktree before running commands.
2. Read the worktree's root `AGENTS.md`.
3. Read any more specific `AGENTS.md` files within the subtree you will modify.
4. Run build, test, package manager, and project-specific commands from inside the worktree, not from the hub root.

Do not assume a language, framework, package manager, or repository structure. Discover tooling from the selected worktree's files.

## Quick Orientation

Useful commands from the hub root:

```sh
# List all worktrees and their branches
git --git-dir=._repo worktree list

# Enter the primary worktree
cd main

# Enter a feature worktree
cd features/<id>-<slug>

# Enter a hotfix worktree
cd bug-fixes/<id>-<slug>
```

## General Rules

- Never edit files under `._repo/`.
- Execute project commands only from within the selected worktree.
- Treat `local/` as confidential.
- Keep hub-level documentation separate from worktree-specific documentation.
- When multiple `AGENTS.md` files apply, the closest one to the files being modified takes precedence.
- If project conventions are unclear, inspect the selected worktree before making assumptions.
EOF
      fi

      if [[ ! -e "$target/documentation/AGENTS.md" && ! -L "$target/documentation/AGENTS.md" ]]; then
        cat > "$target/documentation/AGENTS.md" <<'EOF'
# Documentation Hub Instructions

This directory contains hub-level planning material for work that may span one or more worktrees. It is not an application workspace and must not contain implementation code, credentials, local environment values, or generated build artifacts.

These instructions apply to everything under `documentation/`. They override the hub-level `AGENTS.md` for this subtree.

## Feature Documentation Layout

Every new feature gets its own directory:

```text
documentation/<id>-<slug>/
  plan.md
  swarm.md
```

Example:

```text
documentation/001-auth-tier2/
  plan.md
  swarm.md
```

Legacy directories that do not follow this pattern may remain as-is unless the user explicitly asks to migrate them.

## Feature IDs

Feature IDs are deterministic, consecutive, three-digit lowercase hexadecimal numbers.

Rules:

- Format: exactly three lowercase hex digits, `000` through `fff`.
- Directory prefix: `<id>-<slug>`, for example `00a-auth-tier2`.
- Allocate the next ID by scanning existing documentation directories that match `^[0-9a-f]{3}-` and incrementing the highest ID by one.
- If no numbered feature directories exist yet, start at `001`.
- Never generate IDs randomly.
- Never reuse an ID, even if a feature directory was deleted or abandoned.
- Do not skip an ID unless the user explicitly asks.
- If the next ID would exceed `fff`, stop and ask the user how to proceed.

When listing or comparing feature docs, sort by the hexadecimal ID prefix so consecutive features are visually obvious.

## Slugs

Slugs are short, descriptive, and stable.

Rules:

- Use two to three words.
- Use lowercase kebab-case.
- Keep the slug about the feature, not the implementation phase.
- Avoid filler words like `new`, `misc`, `stuff`, `changes`, or `updates`.
- Prefer `auth-tier2`, `storage-lens`, or `tour-mode` over long sentence-like names.

If the user gives a long title, compress it into a two- or three-word slug before creating the directory.

## Required Files

Each numbered feature directory must contain exactly these planning entry points unless the user asks for extra material:

- `plan.md` — the authoritative technical plan.
- `swarm.md` — the execution map for agents and verification.

Additional supporting files are allowed only when they make the plan easier to execute, such as research notes, API traces, screenshots, or test matrices. Keep those files inside the feature directory.

## `plan.md` Standard

Use the current `documentation/orrery-auth-tier2/plan.md` style as the model: concrete, opinionated, implementation-ready, and explicit about tradeoffs.

Required qualities:

- Start with a clear title naming the project or feature.
- State the goal and the user-visible outcome before implementation details.
- Document current state based on verified code or explicitly marked assumptions.
- Define vocabulary and roles early when the feature has domain concepts.
- Include decisions already taken, especially defaults the user can veto.
- Specify endpoint, data model, storage, UI, and workflow changes when relevant.
- Include security, privacy, migration, and failure-mode considerations when relevant.
- Break implementation into ordered phases with merge or verification gates.
- Include a testing section covering unit, integration, e2e, regression, and manual verification where applicable.
- End with explicit non-goals so agents do not widen scope during execution.

Writing rules:

- Prefer tables for matrices, routes, phases, and ownership boundaries.
- Prefer precise file paths and symbols once verified.
- Do not invent line references; only include them after inspecting the code.
- Mark guesses as assumptions and resolve them before execution whenever possible.
- Keep implementation guidance specific enough that an agent can execute without reinterpreting the feature.

## `swarm.md` Standard

Use `auxiliary/swarm.md` as the example model: an execution plan for multiple agents with clear ownership, safe parallelism, and verification handoff.

Required structure:

```markdown
# <ID> — Agent Swarm: Roles & Responsibilities

## Execution Waves

<diagram or concise wave description>

## Agent 1 — <scope>

**Reads first:** <specific plan sections and files>

| #   | Task | Files |
| --- | ---- | ----- |
| 1   | ...  | ...   |

**Do not touch:** <explicit out-of-scope files or areas>

---

## Agent 2 — <scope>

...

---

## Final Verification Agent — <scope>

**Waits on:** <agents or phases>

| #   | Task |
| --- | ---- |
| 1   | ...  |

---

## Handoff Notes

- ...
```

Required qualities:

- State which agents can run in parallel and why their files or responsibilities do not conflict.
- State which agents must run sequentially and what they wait for.
- Give every agent a bounded scope with specific files, plan sections, and verification duties.
- Include a `Do not touch` list for each implementation agent.
- Include one final verification agent or phase that integrates the work, runs tests, checks regressions, and prepares the handoff.
- Call out the riskiest edge cases in `Handoff Notes` so they are not lost between agents.
- Keep the swarm lean. Do not create agents just to mirror headings in the plan.

Agent boundaries should be based on conflict-free ownership. If two agents need to edit the same file, make them sequential or combine them.

## Creating A New Feature Doc

When asked to create documentation for a new feature:

1. Inspect `documentation/` for existing numbered feature directories.
2. Allocate the next three-digit lowercase hexadecimal ID.
3. Derive a two- or three-word kebab-case slug.
4. Create `documentation/<id>-<slug>/`.
5. Create `plan.md` and `swarm.md` in that directory.
6. If the request is only to scaffold, create concise placeholders with the required headings.
7. If the request includes enough product or technical context, write substantive content immediately.

Do not create a worktree from documentation alone unless the user explicitly asks to begin implementation.

## Confidentiality

Documentation may reference architecture, decisions, and test strategy. It must not include secrets, private tokens, local machine credentials, production environment values, or contents from `local/`.

If a plan needs a value that will eventually be secret, name the environment variable and document its purpose, but use placeholders only.
EOF
      fi

      printf 'Hoisted worktree-hub at %s\n' "${target:A}"
      ;;
    *)
      echo "Error: Unknown hoist strategy: $strategy" >&2
      echo "Run 'hoist list' to see available strategies." >&2
      return 1
      ;;
  esac
}
