package("v8")
    set_homepage("https://v8.dev")
    set_description("V8 JavaScript Engine")

    add_urls("https://github.com/v8/v8.git")
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

    on_check(function (package)
        import("core.tool.toolchain")
        import("core.base.semver")

        -- Require C++20
        assert(package:check_cxxsnippets({test = [[
             #include <cstddef>
             #include <iterator>
             struct SimpleInputIterator {
                 using difference_type = std::ptrdiff_t;
                 using value_type = int;
                 int operator*() const;
                 SimpleInputIterator& operator++();
                 void operator++(int) { ++*this; }
             };
             static_assert(std::input_iterator<SimpleInputIterator>);
         ]]}, {configs = {languages = "c++20"}}), "package(v8): require at least C++20.")

        -- Only configured and tested for:
        assert(not package:is_debug() and not package:config("shared") and package:config("runtimes") == "MT",
            "package(v8): only configured for static + release + MT usage")

        if is_host("windows") then
            -- Require MSVC / Visual Studio 2022
            local msvc = package:toolchain("msvc")
            if msvc then
                local vs = msvc:config("vs")
                local year = tonumber(vs)
                assert(year >= 2022, "package(v8): require at least Visual Studio 2022.")
            else
                assert(false, "package(v8): only configured for MSVC on Windows.")
            end
        end
    end)

    on_install("linux", "windows", function (package)
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

        -- A Git account needs to be configured
        os.vrunv("git", {"config", "user.email", "dummy@dummy.com"})
        os.vrunv("git", {"config", "user.name", "Dummy Dummy"})

        -- Prevent long path issue on Windows
        os.vrunv("git", {"config", "--local", "core.longpaths", "true"})

        -- Update repository and dependencies
        -- Clean any local changes to apply patches
        os.vrunv(gclient, {"sync", "-v"}, {envs = envs})

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
        local cxxflags = is_host("windows") and "/Zc:__cplusplus" or ""

        assert(package:has_cxxfuncs("v8::V8::InitializePlatform(0)", {
            configs = {
                languages = "c++20",
                cxxflags = cxxflags
            },
            includes = "v8.h"
        }))
    end)
