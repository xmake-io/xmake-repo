package("acl-dev")
    set_homepage("https://acl-dev.cn")
    set_description("C/C++ server and network library, including coroutine, redis client, http/https/websocket, mqtt, mysql/postgresql/sqlite client with C/C++ for Linux, Android, iOS, MacOS, Windows.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/acl-dev/acl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/acl-dev/acl.git")

    add_versions("v3.6.5", "dba2fe5c70b34d75e2f2ca642bdcb5bad1abe53f116e8162939ecfd6579adabd")
    add_versions("v3.6.4", "2c98f4ff58f774c6dd5e8753a6a32db2045a2d40b77d65b0e5ebdaaffa348285")
    add_versions("v3.6.2", "888fd9b8fb19db4f8e7760a12a28f37f24ba0a2952bb0409b8380413a4b6506b")
    add_versions("v3.6.3", "4c1fe78cc3dbf2843aab440ca638464d1d1e490e81e904115b8f96a88a3b44de")

    add_patches(">=3.6.2", "patches/v3.6.2/build_install_only_static_or_shared.diff", "179136ceec3a54c9d8a60d92bc67d691271ffcf8214160224b0b9339a26cd0a1")
    add_patches(">=3.6.2", "patches/v3.6.2/export_unix.diff", "13376d9374de1b97ec25f709205f927a7157852075c2583e57615b617c45c62d")
    add_patches(">=3.6.2", "patches/v3.6.2/fix_android_install_path.diff", "19917bd1852af4ddecc27ef402ecf9806b89ec78d91e62c806ba00fc05f41e94")
    add_patches(">=3.6.2", "patches/v3.6.2/debundle_zlib.diff", "43043fb8fe84ef8f37a6a637e0447a849d38155e6d6ca20a9512c38023077a04")

    if is_plat("windows") then
        add_configs("vs", {description = "Use Visual Studio buildsystem (.sln/.vcxproj)", default = false, type = "boolean"})
    end

    add_includedirs("include", "include/acl-lib")

    add_deps("cmake")

    if not is_plat("windows") then
        add_links("protocol", "acl_cpp", "fiber_cpp", "fiber", "acl")
    end

    if not is_plat("windows") then
        add_deps("zlib")
    end
    if is_plat("iphoneos", "macosx", "bsd") then
        add_deps("libiconv")
    end

    if is_plat("windows") then
        add_syslinks("ws2_32", "iphlpapi", "kernel32", "user32", "gdi32")
    elseif is_plat("linux", "bsd", "cross") then
        add_syslinks("pthread", "dl")
        if is_plat("bsd") then
            add_syslinks("execinfo")
        end
    end

    on_load(function (package)
        if package:is_plat("iphoneos", "macosx", "bsd") then
            package:add("patches", ">=3.6.2", "patches/v3.6.2/debundle_iconv.diff", "03db2a366167c865eb6bcd73d06b5d87fa3ed87307aa86bc2d0de9528dd29e10")
        end
        if package:is_plat("android") then
            package:add("defines", "ANDROID")
        elseif package:is_plat("macosx") then
            package:add("defines", "MACOSX")
        elseif package:is_plat("linux", "cross") then
            package:add("defines", "LINUX2")
        elseif package:is_plat("bsd") then
            package:add("defines", "FREEBSD")
        end
    end)

    on_install("windows", "android", "iphoneos", "macosx", "linux", "cross", "bsd", function (package)
        if package:is_plat("windows") and package:config("vs") then
            import("package.tools.msbuild")
            for _, vcxproj in ipairs(os.files("**.vcxproj")) do
                -- Switch vs_runtime MD / MDd -> MT / MTd
                if package:has_runtime("MT", "MTd") then
                    io.replace(vcxproj, "MultiThreadedDebugDLL", "MultiThreadedDebug", {plain = true})
                    io.replace(vcxproj, "MultiThreadedDLL", "MultiThreaded", {plain = true})
                    io.replace(vcxproj, "<IgnoreSpecificDefaultLibraries>libcmt;libc</IgnoreSpecificDefaultLibraries>", "", {plain = true})
                    io.replace(vcxproj, "<IgnoreSpecificDefaultLibraries>libcmtd;libcmt;libc</IgnoreSpecificDefaultLibraries>", "", {plain = true})
                end
                -- Disble LTCG
                io.replace(vcxproj, "<WholeProgramOptimization>true</WholeProgramOptimization>", "<WholeProgramOptimization>false</WholeProgramOptimization>", {plain = true})
            end
            os.cp("lib_fiber/c/include/fiber/**", package:installdir("include/acl-lib/fiber"))
            os.cp("lib_protocol/include/**", package:installdir("include/acl-lib/protocol"))
            os.cp("lib_acl_cpp/include/acl_cpp/**", package:installdir("include/acl-lib/acl_cpp"))
            os.cp("lib_acl/include/**", package:installdir("include/acl-lib/acl"))
            os.cp("lib_fiber/cpp/include/fiber/**", package:installdir("include/acl-lib/fiber_cpp"))
            local arch = package:is_arch("x64") and "x64" or "Win32"
            if package:is_arch("arm64") then
                arch = "ARM64"
            end
            local mode = package:is_debug() and "Debug" or "Release"
            if package:config("shared") then
                mode = package:is_debug() and "DebugDll" or "ReleaseDll"
            end
            local configs = {"acl_cpp_vc2022.sln", "/t:lib_acl;libfiber;lib_protocol;lib_acl_cpp;libfiber_cpp"}
            table.insert(configs, "/p:Configuration=" .. mode)
            table.insert(configs, "/p:Platform=" .. arch)
            msbuild.build(package, configs)
            os.cp("**.lib", package:installdir("lib"))
            if package:config("shared") then
                for _, dll in ipairs(os.files("**.dll")) do
                    if not dll:lower():find("71.dll") and not dll:lower():find("vld.dll") then
                        os.cp(dll, package:installdir("bin"))
                    end
                end
            end
        else
            -- Fix windows .pch file
            io.replace("lib_acl_cpp/CMakeLists.txt", [["-Ycacl_stdafx.hpp"]], [[]], {plain = true})
            io.replace("lib_acl_cpp/CMakeLists.txt", [[add_library(acl_cpp_static STATIC ${lib_src})]],
                "add_library(acl_cpp_static STATIC ${lib_src})\ntarget_precompile_headers(acl_cpp_static PRIVATE src/acl_stdafx.hpp)", {plain = true})
            io.replace("lib_acl_cpp/CMakeLists.txt", [[add_library(acl_cpp_shared SHARED ${lib_src})]],
                "add_library(acl_cpp_shared SHARED ${lib_src})\ntarget_precompile_headers(acl_cpp_shared PRIVATE src/acl_stdafx.hpp)", {plain = true})
            if package:is_plat("windows") then
                -- Do not build .gas on windows
                if not package:is_arch("arm.*") then
                    io.replace("lib_fiber/c/CMakeLists.txt", [[enable_language(C CXX ASM)]], [[enable_language(C CXX ASM_MASM)]], {plain = true})
                    io.replace("lib_fiber/c/CMakeLists.txt", [["-D_WINSOCK_DEPRECATED_NO_WARNINGS"]], [["-DBOOST_CONTEXT_EXPORT="
"-D_WINSOCK_DEPRECATED_NO_WARNINGS"]], {plain = true})
                    if package:check_sizeof("void*") == "8" then
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[list(APPEND lib_src ${src}/fiber/boost/make_gas.S]],
                            [[list(APPEND lib_src ${src}/fiber/boost/make_x86_64_ms_pe_masm.asm]], {plain = true})
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[${src}/fiber/boost/jump_gas.S)]],
                            [[${src}/fiber/boost/jump_x86_64_ms_pe_masm.asm)]], {plain = true})
                    else
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[list(APPEND lib_src ${src}/fiber/boost/make_gas.S]],
                            [[list(APPEND lib_src ${src}/fiber/boost/make_i386_ms_pe_masm.asm]], {plain = true})
                        io.replace("lib_fiber/c/CMakeLists.txt", 
                            [[${src}/fiber/boost/jump_gas.S)]],
                            [[${src}/fiber/boost/jump_i386_ms_pe_masm.asm)]], {plain = true})
                    end
                else
                    os.mkdir("cmake")
                    os.cp(path.join(package:scriptdir(), "port", "cmakeasm_armasminformation.cmake"), "cmake/CMakeASM_MARMASMInformation.cmake")
                    os.cp(path.join(package:scriptdir(), "port", "cmakedetermineasm_armasmcompiler.cmake"), "cmake/CMakeDetermineASM_MARMASMCompiler.cmake")
                    os.cp(path.join(package:scriptdir(), "port", "cmaketestasm_armasmcompiler.cmake"), "cmake/CMakeTestASM_MARMASMCompiler.cmake")
                    io.replace("CMakeLists.txt", [[cmake_minimum_required(VERSION 2.8.0)]], [[cmake_minimum_required(VERSION 3.16)]], {plain = true})
                    io.replace("CMakeLists.txt", [[project(acl)]], [[project(acl)
list(APPEND CMAKE_MODULE_PATH cmake)]], {plain = true})
                    io.replace("lib_fiber/c/CMakeLists.txt", [[enable_language(C CXX ASM)]], [[enable_language(C CXX ASM_MARMASM)]], {plain = true})
                    if package:check_sizeof("void*") == "8" then
                        os.cp(path.join(package:scriptdir(), "port", "ontop_arm64_aapcs_pe_armasm.asm"), "lib_fiber/c/src/fiber/boost/ontop_arm64_aapcs_pe_armasm.asm")
                        os.cp(path.join(package:scriptdir(), "port", "jump_arm64_aapcs_pe_armasm.asm"), "lib_fiber/c/src/fiber/boost/jump_arm64_aapcs_pe_armasm.asm")
                        os.cp(path.join(package:scriptdir(), "port", "make_arm64_aapcs_pe_armasm.asm"), "lib_fiber/c/src/fiber/boost/make_arm64_aapcs_pe_armasm.asm")
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[list(APPEND lib_src ${src}/fiber/boost/make_gas.S]],
                            [[list(APPEND lib_src ${src}/fiber/boost/make_arm64_aapcs_pe_armasm.asm]], {plain = true})
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[${src}/fiber/boost/jump_gas.S)]],
                            [[${src}/fiber/boost/jump_arm64_aapcs_pe_armasm.asm)]], {plain = true})
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[add_definitions("-DFIBER_DLL -DFIBER_EXPORTS")]],
                            [[add_definitions("-D FIBER_DLL -D FIBER_EXPORTS")]], {plain = true})
                    else
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[list(APPEND lib_src ${src}/fiber/boost/make_gas.S]],
                            [[list(APPEND lib_src ${src}/fiber/boost/make_arm_aapcs_pe_armasm.asm]], {plain = true})
                        io.replace("lib_fiber/c/CMakeLists.txt",
                            [[${src}/fiber/boost/jump_gas.S)]],
                            [[${src}/fiber/boost/jump_arm_aapcs_pe_armasm.asm)]], {plain = true})
                    end
                end
            else
                io.replace("CMakeLists.txt", "project(acl)", "project(acl)\nfind_package(ZLIB)", {plain = true})
            end
            if package:is_plat("iphoneos", "macosx", "bsd") then
                if package:is_plat("bsd") then
                    -- FreeBSD enforce fallback to system iconv
                    io.replace("lib_acl_cpp/CMakeLists.txt", [[elseif(CMAKE_SYSTEM_NAME MATCHES "FreeBSD")]], 
                        [[elseif(CMAKE_SYSTEM_NAME MATCHES "FreeBSD")
                        add_definitions("-DUSE_SYS_ICONV")]], {plain = true})
                end
                io.replace("CMakeLists.txt", "project(acl)", "project(acl)\nfind_package(Iconv)", {plain = true})
            end
            for _, file in ipairs(os.files("**.txt")) do
                -- Disable -Wstrict-prototypes -Werror -Qunused-arguments
                io.replace(file, [["-Wstrict-prototypes"]], "", {plain = true})
                io.replace(file, [["-Werror"]], "", {plain = true})
                io.replace(file, [[-Qunused-arguments]], [[]], {plain = true})
                -- Do not enforce LTO
                io.replace(file, [[add_definitions("-flto")]], [[]], {plain = true})
                io.replace(file, [[-flto]], [[]], {plain = true})
                if package:is_plat("windows") then
                    -- Cleanup ZLIB after patch for Windows OS
                    io.replace(file, [[ZLIB::ZLIB]], [[]], {plain = true})
                end
            end
            local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
            if package:is_plat("iphoneos") then
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Darwin")
            end
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "DEBUG" or "RELEASE"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DACL_BUILD_SHARED=" .. (package:config("shared") and "YES" or "NO"))
            import("package.tools.cmake").install(package, configs)
            if package:is_plat("windows") then
                if package:config("shared") then
                    os.vcp(path.join(package:buildir(), "*/shared/**.lib"), package:installdir("lib"))
                    os.vcp(path.join(package:buildir(), "*/shared/**.dll"), package:installdir("bin"))
                else
                    os.vcp(path.join(package:buildir(), "*/static/**.lib"), package:installdir("lib"))
                end
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
