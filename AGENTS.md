# AGENTS.md

Guidance for AI agents working in xmake-repo, the official xmake package repository.
See also [CONTRIBUTING.md](CONTRIBUTING.md) and [README.md](README.md).

## 1. Workflow

### Branches and PRs

* The only development branch is `dev`. **Never commit to or open PRs against `master`**
  (CI syncs `dev` to `master` hourly; a wrong base pulls unrelated commits into the diff).
* Create a topic branch from the latest `origin/dev` (e.g. `add-<pkg>`, `update-<pkg>`) and open the PR with
  `gh pr create --base dev --head <branch>`. Check `.github/` for a PR template first.
* One package per PR, only the package files. Maintainers use `Squash and merge`.
* English titles: `New package: <name> v<version>` / `Update <name> to <version>`
  (bots use `Auto-update <name> to <version>`; do not hand-edit those).

### Choosing a new package

Pick a maintained, reasonably popular library that is absent from `packages/` (search alternate names too),
preferably with no dependencies, or only dependencies already in the repo, and a simple build. Add only the
latest version unless asked otherwise.

### Verification

* `xmake l scripts/test.lua --shallow -vD <pkg>` (options: `-p`, `-k`, `-m`, `--runtimes`, see README).
  If xmake is unavailable, say so in the PR and at least compile the `on_test` snippet by hand.
* `scripts/test.lua` first runs `scripts/check_versions.lua`, then picks tests from `git diff HEAD^`:
  `packages/` -> package tests, `addons/` -> addon tests (`--addon <name>`), `templates/` -> template tests.
* Versions must be valid semver: `<major>[.<minor>[.<patch>]][-<prerelease>][+<build>]`, optional `v` prefix.
  `1.92.9b` is silently parsed as the older prerelease `1.92.9-b`, and `1.2.3.4` is rejected. Use `1.0.0-beta1` /
  `1.0.0+b` and map back to the real tag with `{version = function ...}` in `add_urls`.
  Never add packages to `legacy_packages`. Check with `xmake l scripts/check_versions.lua <pkg>` (`--all`).
* Get the sha256 from the real archive: `curl -L <url> | sha256sum`. `xmake l scripts/new.lua github:<owner>/<repo>` scaffolds a recipe.
* Reviewers check: base is `dev`, style below, `on_test` present and lean, CI green.

## 2. Layout and naming

* Libraries/tools: `packages/<first char>/<name>/xmake.lua` (digits too, e.g. `packages/7/7z`).
  Addons (`set_kind("addon")`): `addons/<first char>/<name>/xmake.lua`. Do not mix them in one PR.
* Directory name == `package("<name>")`. Names are lowercase, normally the upstream name, words joined by `-`
  (most common) or `_` as upstream does. Check for existing packages under other spellings first.
* Extra files sit beside the recipe: `patches/<version>/<desc>.patch|diff` and `port/xmake.lua` (see section 6).
* Addons: `on_test` uses `package:has_addon({rules = ..., toolchains = ..., templates = ...})`; their deps are
  declared in the recipe (`add_deps("x", {kind = "addon"})`, authoritative) and again in the addon manifest,
  and `scripts/test_addons.lua` fails if the two differ.

## 3. Recipe structure

Model new recipes on similar existing ones (`r/robin-map`, `n/nanobench`, `c/cpp-httplib`, `z/zlib`).

Order: `set_kind`, `set_homepage`, `set_description`, `set_license`, `add_urls`, `add_versions`, `add_patches`,
`set_policy`, `add_configs`, `add_deps`, `on_load`, `on_check`, `on_install`, `on_test`.

* `set_kind`: `"library", {headeronly = true}` for header-only, `"binary"` for tools, also `"toolchain"`,
  `"template"`, `"addon"`; omit for ordinary libraries.
* `set_license`: SPDX id (`MIT`, `Apache-2.0`, `BSL-1.0`, ...).
* `add_urls` / `add_versions`: see "Versions and urls" below.
* `add_configs("<name>", {description = "...", default = false, type = "boolean"})`. `shared` and `debug` already exist;
  for header-only/static-only libs write
  `add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})`.
  Options that change deps/flags are applied in `on_load`, not `on_install`.
* `add_deps("cmake")` for CMake builds (also `ninja`, `meson`, `autoconf`, ...). Dep options go in a table:
  `{optional = true}`, `{kind = "binary"}`, `{configs = {shared = true}}`, `{private = true}`.
  `add_extsources("brew::x", "pacman::x", "apt::x")` lets xmake use a system package.
* Prefer no dependencies; never bundle third-party sources. Avoid unusual constructs (e.g. top-level `return`).

### Versions and urls

* **Order:** new versions go on top (newest first, the dominant style in the repo); keep a single contiguous list.
  Never reorder existing lines. `add_versions("<version>", "<sha256>")`, the sha256 is of the downloaded archive.
* **Semantic versions:** the version string is what users write in `add_requires("pkg 1.2.3")`, so it must be a
  valid semver (see Verification). Strip upstream decoration from it: tag `v1.2.3`, `release-1.2.3` or
  `1.2.3-final` -> version `1.2.3`; `r12` -> `12`; `1_2_3` -> `1.2.3`; date releases `20240116.1` or `2024.02.01`
  are fine. Extra/rebuild suffixes use semver form: `1.0.0-beta1` (older), `1.0.0+1` (newer).
* **`$(version)` in urls** is replaced by the selected version string. Put the tag decoration in the url when it is
  constant (`.../tags/v$(version).tar.gz`, `.../tags/release-$(version).tar.gz`). Keeping the `v` in
  `add_versions("v1.2.3", ...)` with a plain `$(version)` also exists, but for new packages prefer the form that
  matches the neighbouring recipes of the same upstream and do not mix both in one recipe.
* **Version mapper** `{version = function (version) ... end}` when the tag/file name is not a constant decoration
  of the version. The function returns the string put into `$(version)`; `version` is a semver object
  (`version:major()`, `version:minor()`, `tostring(version)`). Common cases:
  * `return version:gsub("%.", "_")` (`1.2.3` -> `1_2_3`), `"%."` -> `""` (`123`), `"%+"` -> `"."`.
  * directory plus file: `return format("%d.%d/babl-%s", version:major(), version:minor(), version)`.
  * lookup table for irregular tags/commits: `local tags = {["1.2.3"] = "rel-1-2-3"}` then `return tags[tostring(version)]`.
  Do not use a mapper for plain `v` prefixes; and when `gsub` is used wrap with parentheses if you need only the string,
  e.g. `return (version:gsub("%.", "_"))`, because `gsub` returns two values.
* **Fallback url:** the `.git` url in the same `add_urls` call (it also enables `add_requires("pkg master")`/branches/commits).
  If the sha256 differs between mirrors, give each url an alias and prefix the versions:
  `add_urls("https://.../x-$(version).tar.gz", {alias = "home"})`, `add_versions("home:1.2.10", "<sha256>")`.
  For a `.git` alias the value is the tag/branch/commit: `add_versions("git:1.2.3", "v.1.2.3")`.
* **Commit snapshots** (no releases): url `.../archive/<commit>.tar.gz`, version is the commit date `YYYY.MM.DD`
  (e.g. `2023.05.10`), not the hash.
* `package:version_str()` gives the version string (e.g. for `os.cd(...)` into the extracted dir or in `format`);
  `package:version()` is nil for git refs/branches, so guard: `if package:version() and package:version():ge("1.2")`.
  Version-specific logic and ranges in `add_patches` use semver comparison (`">=1.2 <2"`, `"1.2.3"`, `"*"`).

## 4. Scripts

All take `function (package)` (`on_fetch` takes `function (package, opt)`).

| Script | Use |
|---|---|
| `on_load` | Cheap, runs for every user. Config/version/platform dependent `package:add("deps"\|"defines"\|"links"\|"syslinks"\|"frameworks"\|"includedirs"\|"cxxflags", ...)`, `package:addenv("PATH", "bin")` for tools. |
| `on_check` | Fail early, before download/build, with a readable message; see "on_check" below. |
| `on_install` | Build and install into `package:installdir()`; the cwd is the source dir. |
| `on_test` | Minimal verification, see below. |
| `on_fetch` | Find a system install, only when `opt.system`: `package:find_package(...)` / `package:find_tool("x", {check = "--version"})`. Often `add_extsources` is enough. |
| `on_component` | Only for packages with `add_components`. |

`before_*`/`after_*` hooks and `on_download` are not used in this repository.

### on_check

Use it when support depends on things a platform filter cannot express: the version, arch/ABI, compiler or
toolchain version, NDK/VS/SDK version, or the required C++ standard. It runs before download and install, so
users (and xmake-repo CI) get a clear error instead of a build failure; the package is simply reported unsupported.

* Report with `assert(<ok>, "package(<name>[ <version range>]): <reason>")` or `raise("package(<name> ...): <reason>")`;
  always name the package, the condition and the reason. Narrow with a platform filter (`on_check("android", ...)`)
  and guard version-specific limits with `package:version()` (nil for git refs):

  ```lua
  if on_check then
      on_check("android", function (package)
          if package:version() and package:version():ge("3.0.0") then
              local ndk = package:toolchain("ndk"):config("ndkver")
              assert(ndk and tonumber(ndk) > 22, "package(ada >=3.0.0) require ndk version > 22")
          end
      end)
  end
  ```

* Wrap it in `if on_check then ... end`: older xmake clients lack the API (the dominant form in the repo).
* Typical checks: `package:is_plat()`/`is_arch("arm.*")`/`version():eq|ge|lt()`/`has_tool("cxx", "clang_cl")`;
  NDK via `package:toolchain("ndk"):config("ndkver")`; MSVC via
  `import("core.tool.toolchain")`, `toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})`,
  `msvc:config("vs")` / `msvc:config("vs_sdkver")` (compare with `import("core.base.semver")`); 64-bit via
  `package:check_sizeof("void*") == "8"`.
* Required C++ standard: `assert(package:check_cxxsnippets({test = [[...]]}, {configs = {languages = "c++20"}}), "package(<name>): require at least C++20.")`.
  Use a small snippet that exercises the feature actually needed, not the whole library.
* Do not use it to hide bugs that should be fixed with a patch or a build option.

### Platform filters

`on_load`/`on_check`/`on_install`/`on_test`/`on_fetch` accept zero or more filter strings before the function
(OR-ed). Syntax: `plat|arch@host|hostarch`, each part optional; no filter means all platforms.

| Form | Examples |
|---|---|
| platform | `"linux"`, `"windows"`, `"macosx"`, `"mingw"`, `"msys"`, `"cygwin"`, `"bsd"`, `"android"`, `"iphoneos"`, `"wasm"`, `"cross"` |
| arch (`,` separates several) | `"linux\|x86_64"`, `"windows\|x64"`, `"macosx\|arm64"` |
| host after `@` (machine running the build) | `"mingw@windows"` (mingw built on Windows); `"@linux"`, `"@windows"` = any target, only on that host (host-only tools, `on_fetch`) |
| negation `!`, wildcard `*` | `"!wasm"`, `"windows\|!arm64"`, `"windows\|!arm*"`, `"@!windows"` |
| `native` arch (not cross-compiling) | `"linux\|native"`, `"macosx\|!native"` (cross only) |
| logic, xmake >= 2.9.1 | `"!wasm and !bsd"`, `"!wasm and (!windows or windows\|!arm64)"` |

Examples: `on_install("windows", "linux", "macosx", function (package) ... end)`, `on_install("!wasm", ...)`.

* List the platforms the package is known to build on (what CI covers); use a negative filter (`"!wasm"`) when it
  works nearly everywhere. If support depends on the compiler/toolchain/version, use `on_check` rather than a filter,
  so users get a clear early error.
* Useful `package` APIs: `config("x")`, `is_plat(...)`, `is_arch(...)`, `is_debug()` (not the older `debug()`),
  `is_cross()`, `version()`, `has_tool(...)`, `has_runtime("MT", "MD")`, `installdir()`, `scriptdir()`.
  Guard host-only steps (running built tools, building a CLI) with `package:is_cross()`. No absolute paths.

### on_test

Keep it as short as possible: one snippet with the minimum API calls proving the header/library compiles and
links; no loops, setup or long examples. Include the real public header, set `languages` to what the library needs.

```lua
on_test(function (package)
    assert(package:check_cxxsnippets({test = [[
        void test() {
            foo::bar();
        }
    ]]}, {configs = {languages = "c++17"}, includes = "foo/foo.h"}))
end)
```

Alternatives: `check_csnippets`, `assert(package:has_cfuncs("f", {includes = "x.h"}))`, and for binaries
`os.vrun("tool --version")` (guard with `if not package:is_cross()`).

### Advanced package APIs (rare)

Use only when a simple recipe cannot work; copy the patterns from the existing users. Guard newer APIs with
`if <api> then` like `on_check`, so older xmake clients still load the recipe.

* **`on_source`** (`function (package)`): runs before the source is downloaded and decides urls/versions/schemes
  dynamically, e.g. choosing a prebuilt binary or source archive per platform (`c/cmake`, `e/esp32-arduino-libs`).
  Do not use it for static urls; plain `add_urls`/`add_versions` are enough.
* **Schemes** (`add_schemes("binary", "source")`, first one is the default): alternative ways to get the same
  package, each with its own urls/versions/hashes. Configure them in `on_source` via `package:scheme("binary")`
  (`scheme:add("urls", ...)`, `scheme:add("versions", "1.0.0", "<sha256>")`) and select the install logic in
  `on_install` with `package:current_scheme():name()`. Only `c/cmake` uses it now, and it keeps a fallback
  (`package.current_scheme` / `package:data_set("scheme", ...)`) for xmake without scheme support.
* **Components** (`add_components("a", "b", {deps = {...}})` + `on_component`): for one package exposing several
  libraries that users select with `add_packages("pkg", {components = "a"})` (e.g. `f/ftxui`, `o/opencascade`).
  Use `on_component("<name>", function (package, component) ... end)` to set per-component
  `component:add("links"|"syslinks"|"frameworks"|"includedirs"|"defines", ...)`, dependencies on other components
  (`component:add("deps", "dom")`) and `component:add("extsources", "brew::x/x-name")`. Without a component name the
  script configures all components. Do not use components for an ordinary single-library package; use `links` in `on_load`.
* **`set_base("<pkg>")`**: inherit another recipe and override parts, for packages that are variants/aliases of
  another (`c/curl` -> `libcurl`, `g/gsl` -> `microsoft-gsl`); write it as `if set_base then set_base("<pkg>") end`.
  Keep the child minimal; do not copy the parent's versions/scripts.

## 5. Build tool modules

Use `import("package.tools.<tool>").install(package, configs, opt)` and declare the tool in `add_deps`. The module
handles toolchain, cross-compilation, install prefix and shared/static; do not hand-write `CC`/`CFLAGS`. Map recipe
`package:config(...)` onto upstream options. Turn off upstream tests/examples/docs and bundled dependencies.

| Module | Deps | `configs` and notes |
|---|---|---|
| `cmake` (most common) | `cmake` | List of `-D` args, see idiom below. `opt`: `packagedeps`, `cxflags`/`ldflags`/`shflags`, `buildir`, `cmake_generator = "Ninja"` (add `ninja`). Add `-DCMAKE_POSITION_INDEPENDENT_CODE=ON` for static libs if needed. |
| `xmake` | none | For upstream xmake projects or a `port/xmake.lua`. Handles `shared`/static (`kind`), debug/release and cross itself: do not set `configs.kind` (old recipes still do; do not copy). Just `install(package)`, or pass project options when needed, e.g. `{tools = package:config("tools")}` read by `option()`. |
| `meson` | `meson`, `ninja` | List of `-D` args; always include `"-Ddefault_library=" .. (package:config("shared") and "shared" or "static")`. |
| `autoconf` | none on Unix; `autoconf`, `automake`, `libtool`, `pkg-config` only if the source needs `autoreconf` | `--enable-shared=yes\|no` style args; `opt` such as `{cppflags = ..., ldflags = ...}`. |
| `make`, `nmake`, `msbuild` | none | Only for plain Makefiles / `win32.mak` / `.sln` with no better option: `make.build(package, configs, {envs = make.buildenvs(package)})`, then `os.cp` headers/libs to `package:installdir("include"\|"lib")`. |

Rarely used: `scons`, `gn`, `ninja`. Prefer cmake/xmake/meson/autoconf when upstream supports them.

```lua
on_install(function (package)
    local configs = {}
    table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
    table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
    table.insert(configs, "-DFOO_BUILD_TESTS=OFF")
    if package:config("bar") then
        table.insert(configs, "-DFOO_BAR=ON")
    end
    import("package.tools.cmake").install(package, configs)
end)
```

Header-only libraries without a build step just copy headers: `os.cp("include/*", package:installdir("include"))`.

### packagedeps

`opt.packagedeps` (`cmake`, `meson`, `autoconf`) takes a dep name, a list of names, or dep objects
(`package:dep("x")`). The module fetches each library dep (`package:librarydep(name)`) and injects its
defines/includedirs/linkdirs/links into the compiler/linker flags. Use it when the upstream build cannot find an
xmake-provided dep by itself (no or odd `find_package`, no pkg-config, typically Windows or static deps with
transitive links), instead of hand-written `-DFOO_INCLUDE_DIR=` / `-DFOO_LIBRARY=`. Skip it when the dep is already found.

```lua
import("package.tools.cmake").install(package, configs, {packagedeps = {"zlib", "libogg"}})
-- or all library deps:
local packagedeps = {}
for _, dep in ipairs(package:librarydeps()) do table.insert(packagedeps, dep:name()) end
```

## 6. Fixing upstream sources

Prefer a build option/config over patching when upstream offers one. Do not patch just to silence warnings.

* **`add_patches("<version or range>", "patches/<version>/<desc>.patch", "<sha256>")`**: multi-line or structural
  fixes (several hunks, added/removed files). Applied to the unpacked source before `on_install`, the sha256 is
  mandatory, and the patch must apply cleanly from the source root. A remote upstream commit `.patch` url is also
  allowed. In scripts, build paths with `path.join(os.scriptdir(), "patches", ...)`.
* **`io.replace(file, old, new, {plain = true})`** in `on_install`: small one-line tweaks that depend on
  platform/compiler/config/version, e.g. drop `-Werror`, remove `CMAKE_MSVC_RUNTIME_LIBRARY`, change a macro or link
  flag, or force a runtime in a `.vcxproj`. Always pass `{plain = true}` unless a Lua pattern is really needed, keep the
  match short but unique, and guard it with the condition it applies to. Use a patch if the fix is large.
* **`port/xmake.lua`**: when upstream has no usable build system (plain Makefile, sources only, unusable CMake), ship
  a small xmake script (`port/CMakeLists.txt`, `port/config.h.in` for extra files, `port/<version>/` if versions differ):

  ```lua
  on_install(function (package)
      os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
      import("package.tools.xmake").install(package)
  end)
  ```

  The port script is a normal xmake project: `add_rules("mode.debug", "mode.release")`, `target("<name>")`,
  `set_kind("$(kind)")`, `add_files`, `add_includedirs`, `add_headerfiles("(include/**.h)")` (keeps the directory
  layout), `add_requires("zlib")` + `add_packages` for deps declared with `add_deps`, and `includes("@builtin/check")` +
  `configvar_check_*` for `config.h`. Options passed to `install` are read with `option()`/`get_config`. Keep it minimal;
  a tiny script may be written inline with `io.writefile("xmake.lua", [[ ... ]])` (as `z/zlib` does).

### Exporting symbols of Windows shared libraries

Needed only for `windows` + `shared` when upstream has no `__declspec(dllexport)` macros or exports are incomplete.
Do not add it if upstream already supports shared builds.

* CMake: `if package:is_plat("windows") and package:config("shared") then table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON") end`
  (limit with `package:version():le(...)` if newer releases fixed it).
* xmake / `port/xmake.lua`:

  ```lua
  if is_plat("windows") and is_kind("shared") then
      add_rules("utils.symbols.export_all", {export_classes = true})
  end
  ```

  `export_classes = true` also exports C++ classes (omit for pure C). The rule only works for shared targets, rejects
  `set_optimize("smallest")` and cannot be combined with `/GL`.
* Unix: if upstream builds with `-fvisibility=hidden` without export macros, remove the flag (`io.replace`/patch) or
  define the macro, e.g. `add_defines("ZEXPORT=__attribute__((visibility(\"default\")))")`.

## 7. Policies

`set_policy("<name>", value)` at package level (or inside a platform-specific script); use sparingly and only with a reason.

* `package.precompiled` = `false`: never use precompiled binaries for this package.
* `platform.longpaths` = `true`: avoid Windows long-path failures.
* `package.cmake_generator.ninja` = `true|false`: force or avoid Ninja for CMake builds.
* `package.strict_compatibility` = `true`: require exact ABI/config match with dependents.
* `package.msbuild.multi_tool_task`, `build.fence`: rare build workarounds, copy from an existing user.

## 8. Formatting and comments

* `.editorconfig` for `*.lua`: 4 spaces, LF, final newline. No tabs, no CRLF, no trailing whitespace, exactly one
  newline at EOF. Some old recipes violate this; do not copy them and do not reformat unrelated lines
  (`git diff --check`). Keep original line endings in patch files and `port/` files copied from upstream.
* Everything inside `package("x")` is indented 4 spaces, with one blank line between blocks (header/urls, versions,
  patches, configs, deps, scripts) and none inside the version list.
* Break a long multi-argument call after a comma and align continuation lines under the first argument:

  ```lua
  add_urls("https://github.com/<o>/<r>/archive/refs/tags/$(version).tar.gz",
           "https://github.com/<o>/<r>.git")
  ```

  The same applies to `add_deps(...)`. `add_versions`/`add_patches`/`add_configs` stay on one line even when long;
  so do description strings.
* Keep recipes lean: no comment per line and none that restate code. Comment only key, non-obvious points, in one
  short line: why a patch/`io.replace`/workaround exists (platform, compiler, version, upstream issue/commit),
  version-specific hacks, unusual platform filters. No commented-out code or TODO noise.

## 9. Updating existing packages

* Add only what was asked (usually the latest version). **Do not remove or reorder existing versions, urls, patches or
  version-mapping logic** unless required; reviewers reject unrelated changes (e.g. "why remove them?").
* Keep the existing url scheme; add a `{version = ...}` mapper only when upstream tags changed.
* Keep the diff minimal and do not fix unrelated issues in the same PR.
