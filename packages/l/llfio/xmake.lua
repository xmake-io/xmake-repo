package("llfio")
    set_homepage("https://github.com/ned14/llfio")
    set_description("UTF8-CPP: UTF-8 with C++ in a Portable Way")
    set_license("Apache-2.0")

    local versions = {
        ["2022.9.7"] = "4ed331368afa8e7fdb2ecb02352b578c2a4c7349a8a45c1b34b85f658208a39b"
    }
    local hashes = {
        ["2022.9.7"] = "ae7f9c5a92879285ad5100c89efc47ce1cb0031b"
    }
    add_urls("https://github.com/ned14/llfio/archive/refs/tags/all_tests_passed_$(version).tar.gz", {version = function (version)
        return hashes[tostring(version)]
    end})
    add_urls("https://github.com/ned14/llfio.git")

    add_configs("headeronly", {description = "Use header only version.", default = false, type = "boolean"})
    add_configs("cpp20", {description = "Use C++20 version.", default = false, type = "boolean"})
    add_configs("enable_openssl", {description = "Enable openssl.", default = false, type = "boolean"})
    add_configs("experimental_status_code", {description = "Use experimental_status_code. (not supported atm)", default = false, type = "boolean", readonly})

    for version, commit in pairs(versions) do
        add_versions(version, commit)
    end

    if is_plat("android") then
        add_defines("QUICKCPPLIB_DISABLE_EXECINFO")
    end
    if is_plat("windows") then
        add_defines("LLFIO_LEAN_AND_MEAN")
    end
    add_defines("QUICKCPPLIB_USE_STD_BYTE", "QUICKCPPLIB_USE_STD_OPTIONAL")

    add_deps("quickcpplib", "outcome", "ntkernel-error-category")
    on_load("macosx", "iphoneos", "android", "linux", "windows", function(package)
        if package:config("headeronly") then
            package:add("defines", "LLFIO_HEADERS_ONLY=1")
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "advapi32", "user32", "wsock32", "ws2_32", "ole32", "shell32")
            end
        else
            if not package:config("shared") then
                if package:is_plat("windows", "mingw") then
                    package:add("syslinks", "advapi32", "user32", "wsock32", "ws2_32", "ole32", "shell32")
                end
            end
            package:add("defines", "LLFIO_HEADERS_ONLY=0")
        end
        if package:config("cpp20") then
            package:add("defines", "QUICKCPPLIB_USE_STD_SPAN")
        end
        if package:config("experimental_status_code") then
            package:add("defines", "LLFIO_EXPERIMENTAL_STATUS_CODE")
        end
        if package:config("enable_openssl") then
            package:add("deps", "openssl")
        else
            package:add("defines", "LLFIO_DISABLE_OPENSSL=1")
        end
    end)

    on_install("macosx", "iphoneos", "android", "linux", "windows", function (package)
        if package:is_plat("android") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 28, "package(llfio): need ndk api level >= 28 for android")
        end
        local configs = {}
        configs.experimental_status_code = package:config("experimental_status_code")
        configs.cpp20 = package:config("cpp20")
        if package:config("headeronly") then
            configs.kind = "headeronly"
        elseif package:config("shared") then
            configs.kind = "shared"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        io.replace("include/llfio/v2.0/detail/impl/posix/process_handle.ipp", "#ifdef __linux__\n  char **environ = __environ;\n#endif",
            "#ifdef defined(__linux__) && !defined(__ANDROID__)\n  char **environ = __environ;\n#endif", {plain = true})
        io.replace("include/llfio/v2.0/detail/impl/posix/process_handle.ipp", "#ifdef __FreeBSD__\n#include <sys/sysctl.h>\nextern \"C\" char **environ;\n#endif",
            "#ifdef __FreeBSD__\n#include <sys/sysctl.h>\nextern \"C\" char **environ;\n#endif\n#ifdef __ANDROID__\n extern \"C\" char **environ;\n#endif", {plain = true})
        import("package.tools.xmake").install(package, configs)
    end)

    on_test("macosx", "iphoneos", "android", "linux", "windows", function (package)
        local cxxflags = package:has_tool("cxx", "clang", "clangxx") and {"-fsized-deallocation"} or {}
        local version = "17"
        if package:config("cpp20") then
            version = "20"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <llfio/llfio.hpp>
            void test () {
                namespace llfio = LLFIO_V2_NAMESPACE;
                llfio::file_handle fh = llfio::file({}, "foo").value();
            }
        ]]}, {configs = {languages = "c++" .. version, cxxflags = cxxflags, exceptions = "cxx"}}))
    end)
