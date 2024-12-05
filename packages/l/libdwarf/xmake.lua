package("libdwarf")
    set_homepage("https://www.prevanders.net/dwarf.html")
    set_description("Libdwarf is a C library intended to simplify reading (and writing) applications using DWARF2, DWARF3, DWARF4 and DWARF5")
    set_license("LGPL-2.1")

    add_urls("https://github.com/davea42/libdwarf-code/releases/download/v$(version)/libdwarf-$(version).tar.xz",
             "https://github.com/davea42/libdwarf-code.git")

    add_versions("0.11.1", "b5be211b1bd0c1ee41b871b543c73cbff5822f76994f6b160fc70d01d1b5a1bf")
    add_versions("0.11.0", "846071fb220ac1952f9f15ebbac6c7831ef50d0369b772c07a8a8139a42e07d2")
    add_versions("0.10.1", "b511a2dc78b98786064889deaa2c1bc48a0c70115c187900dd838474ded1cc19")
    add_versions("0.10.0", "17b7143c4b3e5949d1578c43e8f1e2abd9f1a47e725e6600fe7ac4833a93bb77")
    add_versions("0.9.2", "c1cd51467f9cb8459cd27d4071857abc56191cc5d4182d8bdd7744030f88f830")
    add_versions("0.9.1", "877e81b189edbb075e3e086f6593457d8353d4df09b02e69f3c0c8aa19b51bf4")
    add_versions("0.9.0", "d3cad80a337276a7581bb90ebcddbd743484a99a959157c066dd30f7535db59b")
    add_versions("0.8.0", "771814a66b5aadacd8381b22d8a03b9e197bd35c202d27e19fb990e9b6d27b17")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("zlib", "zstd")
    if is_plat("windows", "mingw") then
        add_links("dwarf")
    end

    on_install(function (package)
        if is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "LIBDWARF_STATIC=1")
        end

        local version = package:version()
        if package:gitref() or version:ge("0.9.2") then
            -- https://github.com/davea42/libdwarf-code/pull/226
            io.replace("CMakeLists.txt", "find_package(zstd)", "find_package(zstd CONFIG REQUIRED)", {plain = true})
            io.replace("src/lib/libdwarf/CMakeLists.txt", [[install(FILES "${PROJECT_SOURCE_DIR}/cmake/Findzstd.cmake" DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/libdwarf")]], "", {plain = true})
        else
            io.replace("CMakeLists.txt", "find_package(ZSTD)", "find_package(zstd CONFIG REQUIRED)", {plain = true})
            io.replace("src/lib/libdwarf/CMakeLists.txt", [[install(FILES "${PROJECT_SOURCE_DIR}/cmake/FindZSTD.cmake" DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/libdwarf")]], "", {plain = true})
        end
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
        if not package:config("tools") then
            io.replace("CMakeLists.txt", "add_subdirectory(src/bin/dwarfdump)", "", {plain = true})
        end
        if package:is_plat("windows") then
            io.replace("src/lib/libdwarf/libdwarf_private.h", "typedef long long off_t;", "#include <sys/types.h>", {plain = true})
            io.replace("src/lib/libdwarf/libdwarf_private.h", "typedef long off_t;", "#include <sys/types.h>", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_NON_SHARED=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_DWARFDUMP=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DWARFGEN=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:gitref() or version:ge("0.9.1") then
            local includedir = package:installdir("include/libdwarf")
            os.mkdir(includedir)
            os.cp(package:installdir("include/*.h"), includedir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dwarf_debug_addr_by_index", {includes = "libdwarf/libdwarf.h"}))
    end)
