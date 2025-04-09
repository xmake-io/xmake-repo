package("v8")
    set_homepage("https://v8.dev")
    set_description("V8 JavaScript Engine")

    add_urls("https://github.com/v8/v8.git")
    add_versions("13.3.415.19", "fe051262efbbd92479a08436f733eba9f756e008")
    add_versions("13.4.114.19", "a57459aad9ec3ed5f78d9ded700d52e31029efd2")
    add_versions("13.5.212.10", "e2591684c45463aa1e46ebefc3fd35deee63f37c")

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
        os.vrun("git config --global core.longpaths true")

        -- Update repository and dependencies
        -- Clean any local changes to apply patches
        os.vrunv(gclient, {"sync", "--reset", "--delete_unversioned_trees", "-v"}, {envs = envs})

        -- Fix GN issue
        local patchPath = path.join(package:scriptdir(), "patches", package:version() .. ".patch")

        if os.exists(patchPath) then
            local sourcePath = path.join(package:cachedir(), "source", "v8")
            local cwd = os.cd(sourcePath)

            os.execv("git", {"apply", patchPath})

            os.cd(path.join("third_party", "partition_alloc"))
            os.execv("git", {"add", path.join("src", "partition_alloc", "BUILD.gn")})
            os.execv("git", {"commit", "-m", "xmake-patch-01"})

            os.cd(cwd)
        end

        -- Setup args.gn
        local configs = {
            is_official_build = false,
            is_component_build = false,
            is_debug = package:debug(),
            symbol_level = package:debug() and 2 or 0,
            strip_debug_info = not package:debug(),
            treat_warnings_as_errors = false,
            use_custom_libcxx = false,
            v8_monolithic = true,
            v8_enable_sandbox = false,
            v8_enable_pointer_compression = false,
            v8_enable_webassembly = false,
            v8_enable_gdbjit = package:debug(),
            v8_enable_i18n_support = false,
            v8_enable_test_features = false,
            v8_use_external_startup_data = false
        }

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
