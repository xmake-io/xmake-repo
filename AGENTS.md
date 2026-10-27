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

## Package layout and naming

* Recipe path: `packages/<first char>/<name>/xmake.lua`; the directory is the lowercase first character of
  the name (digits too, e.g. `packages/7/7z`). Directory name == `package("<name>")` name.
* Names are all lowercase (no uppercase anywhere in the repo), usually the upstream name; words are joined
  with `-` (most common) or `_` as upstream does. Check existing/alternate names first to avoid duplicates
  (e.g. `robin-map`, `tl_expected`, `toml++`).
* Patches: `packages/<l>/<name>/patches/<version>/<desc>.patch|diff` (the `<version>` dir convention is used by
  hundreds of packages). Reference with `add_patches("<version-range>", "patches/<version>/x.patch", "<sha256>")`
  (a version or a range like `">=0.43.2 <1.0"`; a remote commit `.patch` url is also allowed), and when the
  path is needed in a script use `path.join(os.scriptdir(), "patches", ...)`.
* Use four spaces, LF, final newline (`.editorconfig`). No tabs, no comments that restate code.

## Recipe style

Follow a similar existing recipe (`packages/r/robin-map`, `packages/n/nanobench`, `packages/c/cpp-httplib`, `packages/z/zlib`):

* Order: `set_kind` (if not default), `set_homepage`, `set_description`, `set_license` (SPDX id, e.g. `MIT`,
  `Apache-2.0`, `BSL-1.0`), `add_urls` (or `set_urls`), `add_versions`, `add_patches`, `add_configs`,
  `add_deps`, `on_load`, `on_install`, `on_test`.
* Sources: prefer GitHub tag archives `https://github.com/<o>/<r>/archive/refs/tags/$(version).tar.gz`
  followed by the `.git` url as fallback (second arg of the same `add_urls`). Use a `{version = function ...}`
  mapper only when the tag differs from the version string.
* `add_versions("<version>", "<sha256>")`: the version string equals the tag minus `$(version)` prefix handling
  (keep the `v` in `add_versions("v1.2.3", ...)` when the url uses plain `$(version)`); newest first;
  the sha256 is of the downloaded archive (verify it, do not guess).
* `set_kind`: `"library", {headeronly = true}` for header-only, `"binary"` for tools, `"toolchain"`, `"template"`,
  `"addon"`; omit for ordinary libs.
* Configs: `add_configs("<name>", {description = "...", default = false, type = "boolean"})`. For the common
  build-type configs rely on the default `shared` (and `{readonly = true}` for header-only/static-only
  libs: `add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})`).
  Set dependent options in `on_load` (`package:add("deps", ...)`, `package:add("defines", ...)`, `package:add("links", ...)`),
  not in `on_install`.
* Deps: `add_deps("cmake")` for cmake builds (also `"ninja"`, `"meson"`, `"autoconf"`...); options go in a table,
  e.g. `add_deps("zlib", {optional = true})`, `{kind = "binary"}`, `{configs = {shared = true}}`, `{private = true}`.
  Use `add_extsources("brew::x", "pacman::x", "apt::x")` for system-package fallback.
* `on_install`: platform filters are positional strings before the function, e.g.
  `on_install("windows", "linux", "macosx", function (package) ... end)`, `on_install("!wasm", ...)`,
  `on_install("windows|x64", ...)`; no filter if it works everywhere. Build with
  `import("package.tools.cmake").install(package, configs)` (also `xmake`, `meson`, `autoconf`, `make`, `msbuild`...)
  where `configs` is built by the standard idiom:
  ```lua
  local configs = {}
  table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
  table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
  table.insert(configs, "-DFOO_BUILD_TESTS=OFF")   -- turn off tests/examples/docs
  if package:config("bar") then table.insert(configs, "-DFOO_BAR=ON") end
  import("package.tools.cmake").install(package, configs)
  ```
  Use `package:is_debug()` (not the older `package:debug()`), `package:config("x")`, `package:is_plat(...)`,
  `package:is_arch(...)`, `package:has_tool(...)`; never hard-code absolute paths, install into `package:installdir()`.
* Header-only libs without a build system: `os.cp("include/*", package:installdir("include"))`
  (or the specific header dir); with a CMake that only installs headers, `import("package.tools.cmake").install`.
* `on_test`: as short as possible (one snippet, the minimum API calls that prove the header links/compiles; no loops, no extra setup, no long examples); `assert(package:check_cxxsnippets({test = [[ void test() { ... } ]]}, {configs = {languages = "c++17"}, includes = "x.h"}))`
  or `check_csnippets`, `assert(package:has_cfuncs("f", {includes = "x.h"}))`, and for binaries
  `os.vrun("tool --version")` (add `if not package:is_cross()`). Set `languages` to what the library needs
  (`c++11/14/17/20`, `c11`), wrap the snippet in `void test() {}` and include the real public header.
* Lifecycle scripts (all take `function (package)`; `on_fetch` takes `function (package, opt)`):
  * `on_load`: runs at load time for every user (cheap, no building). Use it for config-dependent
    `package:add("deps"|"defines"|"links"|"syslinks"|"frameworks"|"includedirs"|"cxxflags", ...)` and
    `package:add("deps", ...)` that depend on `package:config(...)`/version/platform. Accepts platform filters.
  * `on_check`: validates support early and fails fast: `assert(cond, "package(name): unsupported on <plat>|<arch>")`
    or `raise(...)`; typical checks `package:is_plat/is_arch/version():eq/ge`, a compiler/VS version via
    `toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})`, or a `check_cxxsnippets` for the
    required C++ standard. Use it instead of a failing `on_install` for known-unsupported platforms/versions;
    guard with `if on_check then` only if you need old xmake compatibility (the repo does for old clients).
  * `on_install`: do the build/copy into `package:installdir()`; the source dir is the cwd. Filter by platform
    instead of `if is_plat` inside when a whole platform is unsupported.
  * `on_test`: runs after install; keep it minimal (see above). Filters allowed, e.g. `on_test("windows", ...)`.
  * `on_fetch`: finds a system/prebuilt install; only when `opt.system` is set, return
    `package:find_package("x", {...})`/`package:find_tool("x", {check = "--version"})`; otherwise prefer `add_extsources`.
  * Platform filter strings (positional, before the function, OR-ed): `"linux"`, `"macosx"`, `"windows"`, `"mingw"`,
    `"msys"`, `"bsd"`, `"android"`, `"iphoneos"`, `"wasm"`, `"cross"`; with arch `"windows|x64"`, `"macosx|arm64"`,
    `"linux|x86_64"`; negation `"!wasm"`, `"windows|!arm64"`, patterns `"windows|!arm*"`; `"@linux"`/`"@macosx"`/`"@windows"`/`"@msys"`
    mean the *host* platform (used by `on_fetch`/tools), not the target.
  * Binaries/tools: `package:addenv("PATH", "bin")` (in `on_load` or `on_install`), `package:set("kind", ...)`
    only inside `on_load`; run installed tools with `os.vrun("tool --version")` in `on_test` (`if not package:is_cross()`).
  * `on_component` is only for multi-component packages (`add_components`); do not use it for ordinary libs.
  * Do not use `before_*`/`after_*` hooks or `on_download`; they are not used in this repository.
* Policies (`set_policy`, at package level after `set_license`/urls; use sparingly, only with a reason):
  * `package.precompiled` `false`: do not use precompiled binaries for this package.
  * `platform.longpaths` `true`: avoid Windows long path failures (also valid inside `on_install` for a platform).
  * `package.cmake_generator.ninja` `true|false`: force/avoid the Ninja generator for CMake builds.
  * `package.strict_compatibility` `true`: require exact ABI/config match with dependents.
  * `package.msbuild.multi_tool_task` / `build.fence`: rare build-system workarounds, copy from an existing user.
* Cross-compiling: guard host-only steps (running built tools, CLI builds) with `package:is_cross()`.
* Prefer packages with no deps or deps already in the repo; do not bundle third-party sources.
* Avoid unusual constructs (e.g. top-level `return`) in recipes.

## Comments

* Keep recipes lean: do not comment every line or restate what the code does.
* Comment only at key points that are not obvious: why a patch/`io.replace`/workaround exists (link the
  upstream issue/commit or name the platform/compiler/version affected), version-specific hacks, and
  non-obvious platform filters. One short line is enough.
* Do not leave commented-out code, TODO noise, or generated boilerplate comments.

## Fixing upstream sources: add_patches vs io.replace

* `add_patches("<version or range>", "patches/<ver>/<desc>.patch", "<sha256>")`: for multi-line or structural
  fixes (several hunks, new/removed files, anything that must track the upstream diff). The patch applies to
  the unpacked source before `on_install`; the file sha256 is mandatory. Patch files must apply cleanly with
  `git apply`/`patch -p1` from the source root. A remote upstream commit `.patch` url is allowed (with sha256).
* `io.replace(file, old, new, {plain = true})` inside `on_install`: for small one-line tweaks, conditional by
  platform/compiler/config/version (e.g. drop `-Werror`, remove `CMAKE_MSVC_RUNTIME_LIBRARY`, change a macro
  or a link flag, force a runtime in a `.vcxproj` per `package:has_runtime("MT")`). Always pass `{plain = true}`
  unless you really need a Lua pattern, keep the match string short but unique, and guard it with the
  condition it applies to. If the same fix is needed for all platforms and spans many lines, use a patch.
* Prefer passing a build option/config over patching when upstream provides one. Do not patch just to
  silence warnings or fix style.

## Custom build scripts (port xmake.lua)

* When upstream has no usable build system (plain Makefile, hand-written/hostile CMake, only sources), ship a
  small build script in the package dir: `packages/<l>/<name>/port/xmake.lua` (also `port/CMakeLists.txt`,
  `port/config.h.in`, etc. for extra generated files, or `port/<version>/xmake.lua` if versions differ).
* Copy it over the source in `on_install`, then build with the xmake tool:
  ```lua
  on_install(function (package)
      os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
      local configs = {}
      if package:config("shared") then configs.kind = "shared" end
      import("package.tools.xmake").install(package, configs)
  end)
  ```
  (`path.join(package:scriptdir(), ...)` is the dominant form; extra `configs` become `--name=value` options
  that the port script reads via `option("name")`/`has_config`/`get_config`.)
* The port script is a normal xmake project: `add_rules("mode.debug", "mode.release")`, `target("<name>")`,
  `set_kind("$(kind)")` so `shared` works, `add_files`, `add_includedirs`, and `add_headerfiles("(include/**.h)")`
  so headers are installed with their directory; use `add_requires("zlib")`/`add_packages` for deps declared
  with `add_deps` in the recipe, `includes("@builtin/check")` + `configvar_check_*` for config.h checks, and
  `add_rules("utils.symbols.export_all", {export_classes = true})` for Windows shared libs.
* For a tiny script (a few lines) write it inline with `io.writefile("xmake.lua", [[ ... ]])` instead of a port file.
* Keep the port script minimal: just what is needed to build and install the library.

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
