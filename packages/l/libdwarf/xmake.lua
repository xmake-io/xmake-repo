package("libdwarf")

    set_homepage("https://www.prevanders.net/dwarf.html")
    set_description("Libdwarf is a C library intended to simplify reading (and writing) applications using DWARF2, DWARF3, DWARF4 and DWARF5")

    add_urls("https://github.com/davea42/libdwarf-code/releases/download/v$(version)/libdwarf-$(version).tar.xz")
    add_versions("0.8.0", "771814a66b5aadacd8381b22d8a03b9e197bd35c202d27e19fb990e9b6d27b17")
    add_versions("0.9.0", "d3cad80a337276a7581bb90ebcddbd743484a99a959157c066dd30f7535db59b")

    add_deps("cmake")
    add_deps("zlib", "zstd")
    if is_plat("windows", "mingw") then
        add_links("dwarf")
    end

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_NON_SHARED=" .. (package:config("shared") and "OFF" or "ON"))

        if is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "LIBDWARF_STATIC=1")
        end

        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_INSTALL_PREFIX='./'")
            io.replace("src/lib/libdwarf/libdwarf_private.h", "typedef long long off_t;", "#include <sys/types.h>", {plain = true})
            io.replace("src/lib/libdwarf/libdwarf_private.h", "typedef long off_t;", "#include <sys/types.h>", {plain = true})
        end

        io.replace("CMakeLists.txt", "add_subdirectory(src/bin/dwarfdump)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dwarf_debug_addr_by_index", {includes = "libdwarf/libdwarf.h"}))
    end)
