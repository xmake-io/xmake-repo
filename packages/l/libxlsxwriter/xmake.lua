package("libxlsxwriter")
    set_homepage("https://libxlsxwriter.github.io")
    set_description("A C library for creating Excel XLSX files.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/jmcnamara/libxlsxwriter/archive/refs/tags/RELEASE_$(version).tar.gz",
             "https://github.com/jmcnamara/libxlsxwriter.git")

    add_versions("1.1.5", "12843587d591cf679e6ec63ecc629245befec2951736804a837696cdb5d61946")

    add_deps("cmake")
    add_deps("minizip", "zlib")

    on_install(function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DUSE_STATIC_MSVC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if package:is_debug() then
                io.replace("CMakeLists.txt", [[set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /Fd\"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb\"")]], "", {plain = true})
            else
                io.replace("CMakeLists.txt", [[set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /Ox /Zi /Fd\"${CMAKE_BINARY_DIR}/${PROJECT_NAME}.pdb\"")]], "", {plain = true})
            end
        end

        io.replace("CMakeLists.txt", [["1.0"]], "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("workbook_new", {includes = "xlsxwriter.h"}))
    end)
