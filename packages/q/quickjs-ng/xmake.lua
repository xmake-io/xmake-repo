package("quickjs-ng")
    set_homepage("https://github.com/quickjs-ng/quickjs")
    set_description("QuickJS, the Next Generation: a mighty JavaScript engine")
    set_license("MIT")

    add_urls("https://github.com/quickjs-ng/quickjs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/quickjs-ng/quickjs.git", {submodules = false})

    add_versions("v0.12.1", "c2c54b76ca2f52ffea49658a61c5111449cfe0f94e62510bd3bd7a12e2e18884")
    add_versions("v0.11.0", "b456e6aa05522eed9cbf9dec1e947ba1ba6578fd09386391e581339ddabaa641")
    add_versions("v0.9.0", "77f9e79b42e2e7cff9517bae612431af47e120730286cb1dcfad0753bc160f10")
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
        on_check("iphoneos", function (package)
            if package:version() and package:version():le("v0.11.0") then
                raise("package(quickjs-ng <=v0.11.0) unsupported ios platform")
            end
        end)
    end

    on_install(function (package)
        io.replace("CMakeLists.txt", "xcheck_add_c_compiler_flag(-Werror)", "", {plain = true})
        io.replace("CMakeLists.txt", "if(NOT WIN32 AND NOT EMSCRIPTEN)", "if(0)", {plain = true})
        if package:is_plat("wasm") then
            io.replace("quickjs-libc.c", " defined(__wasi__)", " (defined(__wasi__) || defined(EMSCRIPTEN))", {plain = true})
            io.replace("quickjs-libc.c", " !defined(__wasi__)", " (!defined(__wasi__) && !defined(EMSCRIPTEN))", {plain = true})
        end
        if package:is_plat("linux", "bsd", "cross") then
            io.replace("CMakeLists.txt", "M_LIBRARIES OR CMAKE_C_COMPILER_ID STREQUAL \"TinyCC\"", "1", {plain = true}) -- m library link
        end
        if package:is_plat("windows") and package:has_tool("cxx", "clang") then
            -- cmake will use lld-link for clang toolchain and can't accept -Wl,--stack,8388608
            io.replace("CMakeLists.txt",
                [[set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--stack,8388608")]],
                [[set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,/STACK:8388608")]], {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DCONFIG_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DCONFIG_MSAN=" .. (package:config("msan") and "ON" or "OFF"))
        table.insert(configs, "-DCONFIG_UBSAN=" .. (package:config("ubsan") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_QJS_LIBC=" .. (package:config("libc") and "ON" or "OFF"))

        table.insert(configs, "-DQJS_ENABLE_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DQJS_ENABLE_MSAN=" .. (package:config("msan") and "ON" or "OFF"))
        table.insert(configs, "-DQJS_ENABLE_UBSAN=" .. (package:config("ubsan") and "ON" or "OFF"))
        table.insert(configs, "-DQJS_BUILD_LIBC=" .. (package:config("libc") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)

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
