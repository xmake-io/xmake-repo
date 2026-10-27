# AGENTS.md

Guidance for AI agents working in xmake-repo, the official xmake package repository.
See also [CONTRIBUTING.md](CONTRIBUTING.md) and [README.md](README.md).

## Branches and PRs

* The default and only development branch is `dev`. **Never commit to or open PRs against `master`**:
  CI syncs `dev` to `master` hourly. A wrong base shows unrelated commits in the PR diff.
* Work on a topic branch created from the latest `origin/dev` (e.g. `add-<pkg>`, `update-<pkg>`).
  Open PRs with `--base dev`, e.g. `gh pr create --base dev --head <branch>`.
* One package per PR. Maintainers use `Squash and merge`, so keep the diff to the package files only.
* Commit/PR titles are in English: `New package: <name> v<version>` or `Update <name> to <version>`.
  Bot PRs use `Auto-update <name> to <version>`; do not hand-edit those flows.
* Check `.github/` for a PR template before opening a PR.

## Package types: library vs addon

* Library packages live in `packages/<l>/<name>/`; **addons** (`set_kind("addon")`) live in
  `addons/<l>/<name>/xmake.lua` (e.g. `addons/e/esp32-devel`). Do not mix them in one PR.
* Addon `on_test` uses `package:has_addon({rules=..., toolchains=..., templates=...})`, not compile snippets.
* Addon deps must be declared in both the recipe (`add_deps("x", {kind = "addon"})`, authoritative) and
  the addon's own manifest; `scripts/test_addons.lua` fails if they differ.
* Test addons with `xmake l scripts/test.lua --addon <name>`; `scripts/test.lua` picks the test set from
  `git diff HEAD^`: `packages/` -> package tests, `addons/` -> addon tests, `templates/` -> template tests.

## Package layout

* Recipe: `packages/<first letter>/<name>/xmake.lua`, name lowercase, matching the upstream name.
* Patches: `packages/<l>/<name>/patches/[<version>/]*.patch|diff`, referenced with `add_patches`.
* Use four spaces, LF, final newline (`.editorconfig`). No tabs, no comments that restate code.

## Recipe style

Follow a similar existing recipe (`packages/r/robin-map`, `packages/n/nanobench`, `packages/z/zlib`):

* Order: `set_kind` (if headeronly), `set_homepage`, `set_description`, `set_license`, `add_urls`,
  `add_versions`, configs, `add_deps`, `on_install`, `on_test`.
* Prefer GitHub release/tag archives: `https://github.com/<o>/<r>/archive/refs/tags/$(version).tar.gz`
  plus the `.git` url as fallback. Use `$(version)` with a `{version = function ...}` only if tags need it.
* Versions are checked by `scripts/check_versions.lua` (run first by `test.lua`, for `packages/` and `addons/`):
  they must be `<major>[.<minor>[.<patch>]][-<prerelease>][+<build>]` with an optional `v` prefix.
  Invalid ones like `1.92.9b` (parsed silently as prerelease `1.92.9-b`, older than `1.92.9`) or `1.2.3.4`
  fail; use `1.0.0-beta1` / `1.0.0+b` and map back to the real tag via `{version = function ...}` in `add_urls`.
  Never add to its `legacy_packages` list. Check with `xmake l scripts/check_versions.lua <pkg>` (`--all` for all).
* `add_versions` lists newest first, with sha256 of the downloaded archive (verify it, do not guess).
* Header-only libs: `set_kind("library", {headeronly = true})` and copy headers in `on_install`.
* Use `import("package.tools.cmake|xmake|meson|autoconf").install(package, configs)` for builds; expose
  `shared`/`debug` via the usual `-DBUILD_SHARED_LIBS` / `-DCMAKE_BUILD_TYPE` configs.
* Prefer packages with no deps or deps already in the repo; do not bundle third-party sources.
* `on_test` must be short and real: `check_cxxsnippets`/`check_csnippets` with correct `includes`
  and `languages`, or `has_cfuncs`. Avoid unusual constructs (e.g. top-level `return`) in recipes.

## Updating existing packages

* Only add what was asked (usually the latest version). **Do not remove or reorder existing versions,
  urls, patches or version-mapping logic** unless required; reviewers reject unrelated changes.
* Keep the existing url scheme, adding a `{version = ...}` mapper only when upstream tags changed.
* Keep the diff minimal; do not fix unrelated issues in the same PR.

## Verification

* Run `xmake l scripts/test.lua --shallow -vD <pkg>` (see README for `-p`, `-k`, `-m`, `--runtimes`).
  If xmake is unavailable, say so in the PR and at least compile the `on_test` snippet by hand.
* Verify sha256 with `curl -L <url> | sha256sum`; `xmake l scripts/new.lua github:<owner>/<repo>` can scaffold.
* Reviewers check: targets `dev`, recipe follows the style above, `on_test` exists and is lean, CI passes.

## Choosing a new package

Pick a maintained, reasonably popular library that is absent from `packages/` (search by name and
alternate names first), preferably with no dependencies and a simple build.
