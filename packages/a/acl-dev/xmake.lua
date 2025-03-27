package("acl-dev")
    set_homepage("https://acl-dev.cn")
    set_description("C/C++ server and network library, including coroutine,redis client,http/https/websocket,mqtt, mysql/postgresql/sqlite client with C/C++ for Linux, Android, iOS, MacOS, Windows, etc..")
    set_license("LGPL-3.0")

    add_urls("https://github.com/acl-dev/acl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/acl-dev/acl.git")

    add_versions("v3.6.2", "888fd9b8fb19db4f8e7760a12a28f37f24ba0a2952bb0409b8380413a4b6506b")

    add_includedirs("include", "include/acl-lib")

    add_deps("cmake")

    on_install(function (package)
        -- Fix static lib install path
        io.replace("lib_fiber/c/CMakeLists.txt", [[ARCHIVE_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_fiber/c/CMakeLists.txt", [[LIBRARY_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[LIBRARY_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_acl/CMakeLists.txt", [[ARCHIVE_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_acl/CMakeLists.txt", [[LIBRARY_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[LIBRARY_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_protocol/CMakeLists.txt", [[ARCHIVE_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_protocol/CMakeLists.txt", [[LIBRARY_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[LIBRARY_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_fiber/cpp/CMakeLists.txt", [[ARCHIVE_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_fiber/cpp/CMakeLists.txt", [[LIBRARY_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[LIBRARY_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_acl_cpp/CMakeLists.txt", [[ARCHIVE_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        io.replace("lib_acl_cpp/CMakeLists.txt", [[LIBRARY_OUTPUT_DIRECTORY ${lib_output_path}/static]], [[LIBRARY_OUTPUT_DIRECTORY "${CMAKE_INSTALL_LIBDIR}"]], {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DACL_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("acl_fiber_recv", {includes = "fiber/lib_fiber.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test() {
                acl::string buf = "hello world!\r\n";
            }
        ]]}, {includes = "acl_cpp/lib_acl.hpp"}))
    end)
