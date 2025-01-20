package("quickjs-ng")
    set_homepage("https://github.com/quickjs-ng/quickjs")
    set_description("QuickJS, the Next Generation: a mighty JavaScript engine")
    set_license("MIT")

    add_urls("https://github.com/quickjs-ng/quickjs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/quickjs-ng/quickjs.git", {submodules = false})

    add_versions("v0.8.0", "7e60e1e0dcd07d25664331308a2f4aee2a88d60d85896e828d25df7c3d40204e")
    add_versions("v0.7.0", "46c45cc2ed174474765dac8e41062998d92c4dd5fd779624da4073d6cd430eeb")
    add_versions("v0.6.1", "276edbb30896cdf2eee12a8bdb5b9c1cc2734eac8c898de6d52268ae201e614d")
    add_versions("v0.5.0", "41212a6fb84bfe07d61772c02513734b7a06465843ba8f76f1ce1e5df866f489")

    add_configs("libc", {description = "Build standard library modules as part of the library", default = false, type = "boolean"})

    if is_plat("linux", "bsd", "cross") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(quickjs-ng) require vs_toolset >= 14.3")
            end
        end)
    end

    on_install(function (package)
        io.replace("CMakeLists.txt", "xcheck_add_c_compiler_flag(-Werror)", "", {plain = true})
        io.replace("CMakeLists.txt", "if(NOT WIN32 AND NOT EMSCRIPTEN)", "if(0)", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCONFIG_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DCONFIG_MSAN=" .. (package:config("msan") and "ON" or "OFF"))
        table.insert(configs, "-DCONFIG_UBSAN=" .. (package:config("ubsan") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_QJS_LIBC=" .. (package:config("libc") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        if package:is_plat("wasm") then
            io.replace("quickjs-libc.c", " defined(__wasi__)", " (defined(__wasi__) || defined(EMSCRIPTEN))", {plain = true})
            io.replace("quickjs-libc.c", " !defined(__wasi__)", " (!defined(__wasi__) && !defined(EMSCRIPTEN))", {plain = true})
        end
        if package:is_plat("linux", "bsd", "cross") then
            io.replace("CMakeLists.txt", "M_LIBRARIES OR CMAKE_C_COMPILER_ID STREQUAL \"TinyCC\"", "1", {plain = true}) -- m library link
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "qjs.pdb"), dir)
        end

        os.trycp("*.h", package:installdir("include"))
        os.trycp(path.join(package:buildir(), "**.a"), package:installdir("lib"))
        os.trycp(path.join(package:buildir(), "**.so"), package:installdir("lib"))
        os.trycp(path.join(package:buildir(), "**.dylib"), package:installdir("lib"))
        os.trycp(path.join(package:buildir(), "**.lib"), package:installdir("lib"))
        os.trycp(path.join(package:buildir(), "**.dll"), package:installdir("bin"))
        package:add("links", "qjs")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("JS_NewRuntime", {includes = "quickjs.h"}))
    end)
