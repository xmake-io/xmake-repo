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
        local configs = {
            is_official_build = false,
            is_component_build = false,
            is_debug = package:debug(),
            is_shared_library = package:config("shared"),
            symbol_level = 0,
            treat_warnings_as_errors = false,
            use_custom_libcxx = false,
            v8_static_library = not package:config("shared"),
            v8_monolithic = true,
            v8_use_external_startup_data = false,
            v8_enable_test_features = false,
            v8_enable_i18n_support = false}
        if package:is_arch("x86") then
            configs.target_cpu    = "x86"
        elseif package:is_arch("x64") then
            configs.target_cpu    = "x64"
        elseif package:is_arch("arm64") then
            configs.target_cpu    = "arm64"
        end
        if not package:is_plat("windows") then
            configs.cc            = package:build_getenv("cc")
            configs.cxx           = package:build_getenv("cxx")
        else
            configs.extra_cflags  = {(package:config("vs_runtime"):startswith("MT") and "/MT" or "/MD")}
        end
        if package:is_plat("macosx") then
            configs.extra_ldflags = {"-lstdc++"}
            local xcode = import("core.tool.toolchain").load("xcode", {plat = package:plat(), arch = package:arch()})
            configs.xcode_sysroot = xcode:config("xcode_sysroot")
        end
        import("package.tools.gn").build(package, configs, {buildir = "out"})
        os.cp("include", package:installdir())
        os.trycp("out/obj/*.a", package:installdir("lib"))
        os.trycp("out/obj/*.lib", package:installdir("lib"))
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
