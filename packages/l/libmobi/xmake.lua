package("libmobi")
    set_homepage("https://github.com/bfabiszewski/libmobi")
    set_description("C library for handling Kindle (MOBI) formats of ebook documents")
    set_license("MIT")

    set_urls("https://github.com/bfabiszewski/libmobi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/bfabiszewski/libmobi.git")

    add_versions("v0.12", "78826d161c02ce93ff1cd62838b4d749df754f52185474b82e4093badf4689c1")

    add_configs("encryption", {description = "Enable encryption", default = false, type = "boolean"})
    add_configs("xmlwriter", {description = "Enable xmlwriter (for opf support)", default = false, type = "boolean"})
    add_configs("libxml2", {description = "Use libxml2 instead of internal xmlwriter", default = false, type = "boolean"})
    add_configs("zlib", {description = "Use zlib", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("libxml2") then
            package:add("deps", "libxml2")
        end
        if package:config("zlib") then
            package:add("deps", "zlib")
        else
            package:add("deps", "miniz", {configs = {cmake = true}})
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        io.replace("CMakeLists.txt", "cmake_minimum_required(VERSION 3.12)", "cmake_minimum_required(VERSION 3.13)", {plain = true})
        io.replace("src/CMakeLists.txt", "${CMAKE_CURRENT_SOURCE_DIR}/xmlwriter.c", "", {plain = true})
        if package:config("libxml2") then
            io.replace("CMakeLists.txt", "find_package(LibXml2 REQUIRED)", "find_package(LibXml2 CONFIG REQUIRED)", {plain = true})
        end
        if not package:config("tools") then
            io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})
        end

        local cmake = io.readfile("CMakeLists.txt") .. [[
            include(GNUInstallDirs)
            install(TARGETS mobi
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            )
            install(FILES src/mobi.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
        ]]

        if not package:config("zlib") then
            cmake = cmake .. [[
                find_package(miniz REQUIRED)
                target_link_libraries(mobi PRIVATE miniz::miniz)
            ]]
        end

        io.writefile("CMakeLists.txt", cmake)

        if not package:config("shared") then
            io.replace("src/mobi.h", "__declspec(dllexport)", "", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DMOBI_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DMOBI_DEBUG_ALLOC=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DUSE_ENCRYPTION=" .. (package:config("encryption") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_LIBXML2=" .. (package:config("libxml2") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_XMLWRITER=" .. (package:config("xmlwriter") and "ON" or "OFF"))

        local opt = {}
        if package:is_plat("windows") then
            opt.cxflags = "-D_CRT_SECURE_NO_WARNINGS"
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:config("shared") then
            io.replace(path.join(package:installdir("include"), "mobi.h"), "__declspec(dllexport)", "__declspec(dllimport)", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mobi_init", {includes = "mobi.h"}))
    end)
