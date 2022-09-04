package("v8")
    set_homepage("https://chromium.googlesource.com/v8/v8.git")
    set_description("V8 JavaScript Engine")

    add_urls("https://github.com/v8/v8.git")
    add_versions("10.0.58", "d75903764c8547b6fc35c7a3fe4991320be03135")

    add_deps("depot_tools")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows") then
        add_syslinks("user32")
    end

    add_links("v8_monolith",
              "v8_initializers",
              "v8_init",
              "v8_compiler",
              "v8_compiler_opt",
              "v8_cppgc_shared",
              "v8_bigint",
              "v8_snapshot",
              "v8_base_without_compiler",
              "v8_libplatform",
              "v8_libbase",
              "torque_base",
              "torque_generated_definitions",
              "cppgc_base",
              "torque_ls_base")

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
        local gclient = is_host("windows") and "gclient.bat" or "gclient"
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
        if package:is_arch("x86", "i386") then
            configs.target_cpu = "x86"
        elseif package:is_arch("x64", "x86_64") then
            configs.target_cpu = "x64"
        elseif package:is_arch("arm64", "arm64-v8a") then
            configs.target_cpu = "arm64"
        end
        if not package:is_plat("windows") then
            configs.cc  = package:build_getenv("cc")
            configs.cxx = package:build_getenv("cxx")
        else
            configs.extra_cflags = {(package:config("vs_runtime"):startswith("MT") and "/MT" or "/MD")}
        end
        if package:is_plat("windows") then
            local v8_arch = package:is_arch("x86", "i386") and "ia32." or "x64."
            local target_dir = v8_arch .. package:debug() and "debug" or "release"
            os.vrunv("python3", {path.join("tools", "clang", "scripts", "update.py")})
            -- os.vrunv("python3", {path.join("tools", "dev", "v8gen.py"), target_dir, "--", "v8_monolithic=true", "v8_use_external_startup_data=false", "use_custom_libcxx=false", "is_component_build=false", "treat_warnings_as_errors=false", "v8_symbol_level=0"})
            io.writefile(os.path("out.gn", target_dir, "args.gn"), [[
                is_debug = false
                target_cpu = "%s"
                is_component_build = false
                use_custom_libcxx = false
                v8_monolithic = true
                v8_use_external_startup_data = false
                treat_warnings_as_errors = false
                v8_symbol_level = 0
            ]]:format(package:is_arch("x86", "i386") and "ia32" or "x64"))
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
        os.trycp("out/obj/*.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("v8::V8::InitializePlatform(0)", {configs = {languages = "c++17"}, includes = "v8.h"}))
    end)
