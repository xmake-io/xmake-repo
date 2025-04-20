package("gperftools")

    set_homepage("https://github.com/gperftools/gperftools")
    set_description("gperftools is a collection of a high-performance multi-threaded malloc() implementation, plus some pretty nifty performance analysis tools.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/gperftools/gperftools/archive/refs/tags/gperftools-$(version).tar.gz",
             "https://github.com/gperftools/gperftools.git")

    add_versions("2.16", "737be182b4e42f5c7f595da2a7aa59ce0489a73d336d0d16847f2aa52d5221b4")
    add_versions("2.15", "3918ff2e21bb3dbb5a801e1daf55fb20421906f7c42fbb482bede7bdc15dfd2e")
    add_versions("2.14", "ab456a74af2f57a3ee6c20462f73022d11f7ffc22e470fc06dec39692c0ee5f3")
    add_versions("2.13", "fd43adbe0419cb0eaaa3e439845cc89fe7d42c22eff7fd2d6b7e87ae2acbce1d")
    add_versions("2.12", "1cc42af8c0ec117695ecfa49ef518d9eaf7b215a2657b51f655daa2dc07101ce")
    add_versions("2.11", "b0d32b3d82da0ddac2a347412b50f97efddeae66dfbceb49455b7262fb965434")
    add_versions("2.10", "b0dcfe3aca1a8355955f4b415ede43530e3bb91953b6ffdd75c45891070fe0f1")

    if is_plat("linux") then
        add_extsources("pacman::gperftools", "apt::libgoogle-perftools-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::gperftools")
    end

    add_configs("minimal", {description = "Build only tcmalloc-minimal (and maybe tcmalloc-minimal-debug)", default = is_plat("windows", "mingw"), type = "boolean"})
    add_configs("tcmalloc", {description = "Use tcmalloc", default = true, type = "boolean"})
    add_configs("profiler", {description = "Use profiler", default = true, type = "boolean"})
    if is_plat("linux") then
        add_configs("unwind", {description = "Enable libunwind support.", default = false, type = "boolean"})
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", "mingw", function (package)
            assert(package:config("minimal"), "package(gperftools): only tcmalloc_minimal is supported on Windows or MinGW")
            if package:is_plat("windows") then
                assert(package:version():ge("2.16") or package:version():eq("2.10"), "package(gperftools): requires version = 2.10 or >= 2.16 for Windows")
            else
                assert(package:version():ge("2.16"), "package(gperftools): requires version >= 2.16 for MinGW")
            end
        end)
        on_check("macosx", function (package)
            if not package:version():ge("2.14") then
                if not (package:version():eq("2.10") and macos.version():le("12")) then
                    raise("package(gperftools): requires version >= 2.14 for macOS")
                end
            end
        end)
    end

    on_load(function (package)
        if package:is_plat("linux") and package:config("unwind") then
            package:add("deps", "libunwind")
        end

        if package:config("tcmalloc") then
            local libsuffix = package:config("minimal") and "_minimal" or ""
            libsuffix = package:is_debug() and libsuffix .. "_debug" or libsuffix
            package:add("links", "tcmalloc" .. libsuffix)
        end

        if package:config("profiler") then
            package:add("links", "profiler")
        end
    end)

    on_install("windows|!arm64", "macosx", "linux", "mingw", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-Dgperftools_build_benchmark=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DGPERFTOOLS_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-Dgperftools_build_minimal=" .. (package:config("minimal") and "ON" or "OFF"))
        if package:is_plat("linux") then
            table.insert(configs, "-Dgperftools_enable_libunwind=" .. (package:config("unwind") and "ON" or "OFF"))
        end

        io.replace("CMakeLists.txt", "if(MINGW OR MSVC)", "if(MINGW OR MSVC)\nlink_libraries(psapi synchronization shlwapi)", {plain = true})
        io.replace("src/windows/port.h", "inline int nanosleep", "extern \"C\" inline int nanosleep", {plain = true})

        if package:version():le("2.15") then
            import("package.tools.cmake").install(package, configs)
        else 
            import("package.tools.cmake").build(package, configs, {buildir = "build"})

            os.trycp("build/gperftools", package:installdir("include"))
            os.trycp("build/**.a", package:installdir("lib"))
            os.trycp("build/**.dylib", package:installdir("lib"))
            os.trycp("build/**.so", package:installdir("lib"))
            os.trycp("build/**.lib", package:installdir("lib"))
            os.trycp("build/**.dll", package:installdir("bin"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tc_version", {includes = "gperftools/tcmalloc.h"}))
    end)
