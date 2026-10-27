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
* Build tool modules (`import("package.tools.<tool>").install(package, configs, opt)`); declare the tool as a dep
  in the recipe (`add_deps(...)`) and let the module handle cross-compile/toolchain/env/install prefix/static-shared:
  * `cmake` (most common): `add_deps("cmake")`; `configs` is a list of `-D` args (idiom above; also set
    `-DCMAKE_POSITION_INDEPENDENT_CODE=ON` for static libs when needed). Optional 3rd arg `opt`:
    `{packagedeps = {"zlib", "libogg"}}` (point cmake at xmake deps, the usual way to wire `add_deps` libs),
    `{cxflags = ...}`/`{ldflags = ...}`/`{shflags = ...}` extra flags, `{buildir = "build"}`, `{cmake_generator = "Ninja"}`
    (`add_deps("ninja")`). Disable tests/examples/docs/bundled-deps via `-D` options.
  * `packagedeps` (3rd-arg option of `cmake`/`meson`/`autoconf`): a dep name, a list of names, or dep objects
    (`package:dep("x")`). The module fetches each library dep (`package:librarydep(name)`, unknown names are
    skipped) and injects its defines/includedirs/linkdirs/links into the compiler and linker flags. Use it when
    the upstream build cannot locate an xmake-provided dep by itself (no/odd `find_package`, pkg-config missing,
    typically on Windows or for static deps and their transitive links), instead of hand-written `-DFOO_INCLUDE_DIR=`/
    `-DFOO_LIBRARY=` paths. Do not add it when the dep is already found via the CMake/pkg-config prefix path.
    ```lua
    import("package.tools.cmake").install(package, configs, {packagedeps = {"zlib", "libogg"}})
    -- or pass all library deps:
    local packagedeps = {}
    for _, dep in ipairs(package:librarydeps()) do table.insert(packagedeps, dep:name()) end
    ```
  * `xmake`: for upstream xmake projects or your `port/xmake.lua`; the module already handles `shared`/static
    (`kind`), debug/release and cross-compile, so do NOT set `configs.kind` yourself (older recipes still do; do not copy it).
    Call `import("package.tools.xmake").install(package)`, or pass a table of project options only when needed,
    e.g. `{tools = package:config("tools")}` read by `option()` in the project, or extra flags like `configs.cxflags = "-fPIC"`.
  * `meson`: `add_deps("meson", "ninja")`; `configs` is a list of `-D` args, always include
    `"-Ddefault_library=" .. (package:config("shared") and "shared" or "static")`; `opt` like `{packagedeps = ...}`.
  * `autoconf`: for `configure` projects; configs are `--enable-shared=` / `--enable-static=` etc. args:
    `table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))`; pass `{cppflags = ..., ldflags = ...}`
    via `opt`. System autotools exist on Unix; add `add_deps("autoconf", "automake", "libtool", "pkg-config")` only if
    the source needs `autoreconf` (no pre-generated `configure`).
  * `make`/`nmake`/`msbuild`: for plain Makefiles / `nmake` (`win32.mak`) / `.sln` projects with no better option:
    `import("package.tools.make").build(package, configs, {envs = make.buildenvs(package)})`, then copy
    headers/libs yourself with `os.cp(..., package:installdir("include"|"lib"))`; `msbuild.build(package, configs)` + `msbuild.buildenvs`.
  * Others used rarely: `scons`, `gn`, `ninja`. Prefer cmake/xmake/meson/autoconf when upstream supports them.
  * Always map `shared`, debug/release and (for toolchains) cross-compile via the module, not by hand-writing
    `CC`/`CFLAGS`; use `package:config(...)` to switch upstream options.
* Exporting symbols for Windows shared libs (upstream has no `__declspec(dllexport)` macros, or the exports are
  incomplete, so the `.dll` has no import lib/symbols): only a fix for `windows` + `shared`; do not use it when
  upstream already supports shared builds properly.
  * CMake projects: `if package:is_plat("windows") and package:config("shared") then table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON") end`
    (restrict by version with `package:version():le(...)` if newer upstream releases fixed it).
  * xmake projects / `port/xmake.lua`:
    ```lua
    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
    ```
    `export_classes = true` also exports C++ classes (needed for C++ libs, omit for pure C libs). The rule
    works only for shared targets, rejects `set_optimize("smallest")`, and conflicts with `/GL` (whole program
    optimization), so do not enable them together. It does not export data from non-DLL-safe designs; if
    that is required, patch the source macros instead (`add_patches`/`io.replace`).
  * Unix visibility: if upstream builds with `-fvisibility=hidden` and omits export macros, fix it with a patch/
    `io.replace` (remove the flag) or a define, e.g. `add_defines("ZEXPORT=__attribute__((visibility(\"default\")))")`;
    do not hide this behind a `check_*` in `on_test`.
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
  * Platform filters (`on_load`/`on_check`/`on_install`/`on_test`/`on_fetch`): zero or more positional string
    args before the function, OR-ed together. Syntax `plat|arch@host|hostarch`, every part optional:
    * no filter = all platforms; `"linux"`, `"windows"`, `"macosx"`, `"mingw"`, `"msys"`, `"cygwin"`, `"bsd"`,
      `"android"`, `"iphoneos"`, `"wasm"`, `"cross"`.
    * arch after `|`, several with `,`: `"linux|x86_64"`, `"windows|x64"`, `"macosx|arm64"`, `"iphoneos|arm64"`.
    * host after `@` (the machine running the build): `"mingw@windows"` = mingw target built on a Windows host;
      `"@linux"`/`"@windows"`/`"@macosx"`/`"@msys"` = any target, only on that host (use for host-only tools,
      e.g. `on_install("@windows", "@linux", "@macosx", ...)`, and for `on_fetch`).
    * negation `!`, wildcard `*`: `"!wasm"`, `"windows|!arm64"`, `"windows|!arm*"`, `"@!windows"`, `"!linux|*"`.
    * `native` arch = the host's own arch, i.e. not cross-compiling: `"linux|native"`, `"macosx|!native"` (cross only).
    * logic (xmake >= 2.9.1) inside one string with `and`/`or`/`()`: `"!wasm and !bsd"`,
      `"!wasm and (!windows or windows|!arm64)"`, `"@!windows and !wasm"`.
  * Choosing the filter: list the platforms the package is actually known to build on (ones CI covers) rather than
    guessing; use a negative filter (`"!wasm"`) when it works nearly everywhere; use `on_check` instead of a filter
    when support depends on the compiler/toolchain/version, so users get a clear early error.
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
      import("package.tools.xmake").install(package)
  end)
  ```
  (`path.join(package:scriptdir(), ...)` is the dominant form; extra options passed to `install` become `--name=value` options
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
