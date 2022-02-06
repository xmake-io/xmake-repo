package("v8")
    set_homepage("https://chromium.googlesource.com/v8/v8.git")
    set_description("V8 JavaScript Engine")

    add_urls("https://github.com/v8/v8.git")
    add_versions("10.0.58", "d75903764c8547b6fc35c7a3fe4991320be03135")

    add_deps("depot_tools")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

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
        local gclient = package:is_plat("windows") and "gclient.bat" or "gclient"
        os.vrunv(gclient, {"sync", "-v"}, {envs = envs})
        --os.vrunv("python3", {"./tools/dev/gm.py", "x64.release"})
        --os.vrunv("python3", {"./tools/dev/v8gen.py", "x64.release"})
        if package:is_plat("macosx") then
            io.writefile("x64.release/args.gn", [[is_component_build = false
is_debug = false
target_cpu = "x64"
use_custom_libcxx = false
v8_monolithic = true
v8_use_external_startup_data = false]])
        else
            io.writefile("x64.release/args.gn", [[target_os = "linux"
is_debug = false
target_cpu = "x64"
use_custom_libcxx = false
clang_use_chrome_plugins = false
is_component_build = false
is_clang = true
v8_static_library = true
v8_monolithic = true
v8_use_external_startup_data = false
v8_enable_test_features = false
v8_enable_i18n_support = false
treat_warnings_as_errors = false
symbol_level = 0]])
        end
        import("package.tools.ninja").build(package, {}, {buildir = "out/x64.release"})
        os.cp("include", package:installdir())
        os.trycp("out/x64.release/obj/**.a", package:installdir("lib"))
        os.trycp("out/x64.release/obj/**.lib", package:installdir("lib"))
        print(os.files("out/**.a"))
        print(os.files("out/**.dylib"))
        print(os.files("out/**.so"))
        print(os.files("out/**.lib"))
        print(os.files("out/**.h"))
        print(os.files("out/**.hpp"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("v8::V8::InitializePlatform(0)", {configs = {languages = "c++17"}, includes = "v8.h"}))
    end)
