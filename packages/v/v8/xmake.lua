package("v8")
    set_homepage("https://v8.dev")
    set_description("V8 JavaScript Engine")

    add_urls("https://github.com/v8/v8.git")
    add_versions("13.3.415.19", "fe051262efbbd92479a08436f733eba9f756e008")

    add_deps("depot_tools")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows") then
        add_syslinks("user32", "winmm", "advapi32", "dbghelp", "shlwapi")
        add_configs("runtimes", {description = "Set runtime.", default = "MT", readonly = true})
    end

    add_includedirs("include", {public = true})
    add_links("v8_monolith")

    on_install("linux", "macosx", "windows", function (package)
        import("core.base.global")

        -- maybe we need set proxy, e.g. `xmake g --proxy=http://127.0.0.1:xxxx`
        local envs = {}
        local proxy = global.get("proxy")
        if proxy then
            envs.HTTP_PROXY = proxy
            envs.HTTPS_PROXY = proxy
            envs.ALL_PROXY = proxy
        end
        io.writefile(".gclient", [=[solutions = [
  {
    "name": ".",
    "url": "https://github.com/v8/v8.git",
    "deps_file": "DEPS",
    "managed": False,
    "custom_deps": {},
  }]]=])

        if package:is_plat("windows") then
            envs.DEPOT_TOOLS_WIN_TOOLCHAIN = "0"
            envs.GYP_MSVS_VERSION = "2022"
        end

        local gclient = is_host("windows") and "gclient.bat" or "gclient"

        -- Prevent long path issue on Windows
        os.vrunv("git", {"config", "--local", "core.longpaths", "true"})

        -- Update repository and dependencies
        -- Clean any local changes to apply patches
        os.vrunv(gclient, {"sync", "-v", "--reset", "--delete_unversioned_trees"}, {envs = envs})

        -- Fix GN issue
        local version = package:version_str()
        local patch_path = path.join(package:scriptdir(), "patches", version, "fix.patch")
        if os.exists(patch_path) then
            local source_path = path.join(package:cachedir(), "source", "v8")
            local fix_path = path.join(source_path, "third_party", "partition_alloc")
            os.execv("git", {"apply", patch_path}, {curdir = source_path})
            os.execv("git", {"add", path.join("src", "partition_alloc", "BUILD.gn")}, {curdir = fix_path})
            os.execv("git", {"commit", "-m", "xmake-patch-01"}, {curdir = fix_path})
        end

        -- Setup args.gn
        local configs = {
            is_official_build = false,
            is_component_build = false,
            is_debug = package:is_debug(),
            symbol_level = package:is_debug() and 2 or 0,
            strip_debug_info = not package:is_debug(),
            treat_warnings_as_errors = false,
            use_custom_libcxx = false,
            v8_monolithic = true,
            v8_enable_sandbox = false,
            v8_enable_pointer_compression = false,
            v8_enable_webassembly = false,
            v8_enable_gdbjit = package:is_debug(),
            v8_enable_i18n_support = false,
            v8_enable_test_features = false,
            v8_use_external_startup_data = false
        }
        if not is_host("windows") then
            configs.is_clang = false
        end

        -- Build V8 library
        import("package.tools.gn").build(package, configs, {buildir = "out.gn", target = {"v8_monolith"}})

        -- Install headers and library files
        os.cp("include", package:installdir())
        os.trycp("out.gn/obj/*.a", package:installdir("lib"))
        os.trycp("out.gn/obj/*.lib", package:installdir("lib"))
        os.trycp("out.gn/obj/*.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("v8::V8::InitializePlatform(0)", {
            configs = {
                languages = "c++20",
                cxxflags = "/Zc:__cplusplus"
            },
            includes = "v8.h"
        }))
    end)
