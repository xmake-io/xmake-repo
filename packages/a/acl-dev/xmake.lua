package("acl-dev")
    set_homepage("https://acl-dev.cn")
    set_description("C/C++ server and network library, including coroutine, redis client, http/https/websocket, mqtt, mysql/postgresql/sqlite client with C/C++ for Linux, Android, iOS, MacOS, Windows.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/acl-dev/acl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/acl-dev/acl.git")

    add_versions("v3.6.2", "888fd9b8fb19db4f8e7760a12a28f37f24ba0a2952bb0409b8380413a4b6506b")

    add_includedirs("include", "include/acl-lib")

    add_deps("cmake")
    if is_plat("cross") then
        add_deps("zlib")
    end

    if is_plat("windows") then
        add_syslinks("ws2_32", "iphlpapi", "kernel32", "user32", "gdi32")
    elseif is_plat("bsd", "linux") then
        add_syslinks("pthread", "dl")
    end


    on_load(function (package)
        if package:is_plat("android") then
            package:add("defines", "ANDROID")
        elseif package:is_plat("macosx") then
            package:add("defines", "MACOSX")
        elseif package:is_plat("linux") then
            package:add("defines", "LINUX2")
        elseif package:is_plat("bsd") then
            package:add("defines", "FREEBSD")
        elseif package:is_plat("sunos5") then
            package:add("defines", "SUNOS5")
        end
    end)

    on_install("android", "iphoneos", "macosx", "linux", "cross", "bsd", "windows", function (package)
        -- Build & install only shared or only static library
        if package:config("shared") then
            io.replace("lib_fiber/c/CMakeLists.txt", "add_library(fiber_static STATIC ${lib_src})",
                "add_library(fiber_static STATIC ${lib_src})\nset_target_properties(fiber_static PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_fiber/c/CMakeLists.txt", "install%(TARGETS fiber_static.-%)", "")

            io.replace("lib_fiber/cpp/CMakeLists.txt", "add_library(fiber_cpp_static STATIC ${lib_src})",
                "add_library(fiber_cpp_static STATIC ${lib_src})\nset_target_properties(fiber_cpp_static PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_fiber/cpp/CMakeLists.txt", "install%(TARGETS fiber_cpp_static.-%)", "")

            io.replace("lib_protocol/CMakeLists.txt", "add_library(protocol_static STATIC ${lib_src})",
                "add_library(protocol_static STATIC ${lib_src})\nset_target_properties(protocol_static PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_protocol/CMakeLists.txt", "install%(TARGETS protocol_static.-%)", "")

            io.replace("lib_acl_cpp/CMakeLists.txt", "add_library(acl_cpp_static STATIC ${lib_src})",
                "add_library(acl_cpp_static STATIC ${lib_src})\nset_target_properties(acl_cpp_static PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_acl_cpp/CMakeLists.txt", "install%(TARGETS acl_cpp_static.-%)", "")

            io.replace("lib_acl/CMakeLists.txt", "add_library(acl_static STATIC ${acl_src})",
                "add_library(acl_static STATIC ${acl_src})\nset_target_properties(acl_static PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_acl/CMakeLists.txt", "install%(TARGETS acl_static.-%)", "")
        else
            io.replace("lib_fiber/c/CMakeLists.txt", "add_library(fiber_shared SHARED ${lib_src})",
                "add_library(fiber_shared SHARED ${lib_src})\nset_target_properties(fiber_shared PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_fiber/c/CMakeLists.txt", "install%(TARGETS fiber_shared.-%)", "")

            io.replace("lib_fiber/cpp/CMakeLists.txt", "add_library(fiber_cpp_shared SHARED ${lib_src})",
                "add_library(fiber_cpp_shared SHARED ${lib_src})\nset_target_properties(fiber_cpp_shared PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_fiber/cpp/CMakeLists.txt", "install%(TARGETS fiber_cpp_shared.-%)", "")

            io.replace("lib_protocol/CMakeLists.txt", "add_library(protocol_shared SHARED ${lib_src})",
                "add_library(protocol_shared SHARED ${lib_src})\nset_target_properties(protocol_shared PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_protocol/CMakeLists.txt", "install%(TARGETS protocol_shared.-%)", "")

            io.replace("lib_acl_cpp/CMakeLists.txt", "add_library(acl_cpp_shared SHARED ${lib_src})",
                "add_library(acl_cpp_shared SHARED ${lib_src})\nset_target_properties(acl_cpp_shared PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_acl_cpp/CMakeLists.txt", "install%(TARGETS acl_cpp_shared.-%)", "")

            io.replace("lib_acl/CMakeLists.txt", "add_library(acl_shared SHARED ${acl_src})",
                "add_library(acl_shared SHARED ${acl_src})\nset_target_properties(acl_shared PROPERTIES EXCLUDE_FROM_ALL 1)", {plain = true})
            io.replace("lib_acl/CMakeLists.txt", "install%(TARGETS acl_shared.-%)", "")
        end

        -- Fix install path for android
        io.replace("lib_protocol/CMakeLists.txt", [[set(lib_output_path ${CMAKE_CURRENT_SOURCE_DIR}/../android/lib/${ANDROID_ABI})]], [[set(lib_output_path )]], {plain = true})
        io.replace("lib_fiber/cpp/CMakeLists.txt", [[set(lib_output_path ${CMAKE_CURRENT_SOURCE_DIR}/../../android/lib/${ANDROID_ABI})]], [[set(lib_output_path )]], {plain = true})
        io.replace("lib_fiber/c/CMakeLists.txt", [[set(lib_output_path ${CMAKE_CURRENT_SOURCE_DIR}/../../android/lib/${ANDROID_ABI})]], [[set(lib_output_path )]], {plain = true})
        io.replace("lib_acl_cpp/CMakeLists.txt", [[set(lib_output_path ${CMAKE_CURRENT_SOURCE_DIR}/../android/lib/${ANDROID_ABI})]], [[set(lib_output_path )]], {plain = true})
        io.replace("lib_acl/CMakeLists.txt", [[set(acl_output_path ${CMAKE_CURRENT_SOURCE_DIR}/../android/lib/${ANDROID_ABI})]], [[set(acl_output_path )]], {plain = true})

        -- Fix windows .pch file
        io.replace("lib_acl_cpp/CMakeLists.txt", [["-Ycacl_stdafx.hpp"]], [[]], {plain = true})
        io.replace("lib_acl_cpp/CMakeLists.txt", [[add_library(acl_cpp_static STATIC ${lib_src})]],
            "add_library(acl_cpp_static STATIC ${lib_src})\ntarget_precompile_headers(acl_cpp_static PRIVATE src/acl_stdafx.hpp)", {plain = true})
        io.replace("lib_acl_cpp/CMakeLists.txt", [[add_library(acl_cpp_shared SHARED ${lib_src})]],
            "add_library(acl_cpp_shared SHARED ${lib_src})\ntarget_precompile_headers(acl_cpp_shared PRIVATE src/acl_stdafx.hpp)", {plain = true})

        -- Fix windows .gas
        if package:is_plat("windows") then
            if package:is_arch("x86", "i386", "i686") then
                io.replace("lib_fiber/c/CMakeLists.txt", [[${src}/fiber/boost/make_gas.S]], [[${src}/fiber/boost/make_i386_ms_pe_gas.asm]], {plain = true})
                io.replace("lib_fiber/c/CMakeLists.txt", [[${src}/fiber/boost/jump_gas.S]], [[${src}/fiber/boost/jump_i386_ms_pe_gas.asm]], {plain = true})
            else
                io.replace("lib_fiber/c/CMakeLists.txt", [[${src}/fiber/boost/make_gas.S]], [[${src}/fiber/boost/make_x86_64_ms_pe_gas.asm]], {plain = true})
                io.replace("lib_fiber/c/CMakeLists.txt", [[${src}/fiber/boost/jump_gas.S]], [[${src}/fiber/boost/jump_x86_64_ms_pe_gas.asm]], {plain = true})
            end
        end

        for _, file in ipairs(os.files("**.txt")) do
            -- Disable -Wstrict-prototypes -Werror
            io.replace(file, [["-Wstrict-prototypes"]], "", {plain = true})
            io.replace(file, [["-Werror"]], "", {plain = true})
            io.replace(file, [[-Qunused-arguments]], [[]], {plain = true})
        end

        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        local packagedeps = {}
        if package:is_plat("iphoneos") then
            table.insert(configs, "-DCMAKE_SYSTEM_NAME=Darwin")
        elseif package:is_plat("cross") then
            table.insert(packagedeps, "zlib")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DACL_BUILD_SHARED=" .. (package:config("shared") and "YES" or "NO"))
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
        if package:is_plat("windows") then
            if package:config("shared") then
                os.vcp(path.join(package:buildir(), "*/shared/**.lib"), package:installdir("lib"))
                os.vcp(path.join(package:buildir(), "*/shared/**.dll"), package:installdir("bin"))
            else
                os.vcp(path.join(package:buildir(), "*/static/**.lib"), package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("acl_fiber_recv", {includes = "fiber/lib_fiber.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test() {
                const char* redis_addr = "127.0.0.1:7000";
                int max_conns = 100;
                acl::redis_client_cluster cluster;
                cluster.set(redis_addr, max_conns);
            }
        ]]}, {includes = "acl_cpp/lib_acl.hpp"}))
    end)
