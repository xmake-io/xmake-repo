package("openvpn3")
    set_kind("library", {headeronly = true})
    set_homepage("https://openvpn.github.io/openvpn3/")
    set_description("OpenVPN 3 is a C++ class library that implements the functionality of an OpenVPN client.")

    add_urls("https://github.com/OpenVPN/openvpn3/archive/refs/tags/release/$(version).tar.gz", {alias = "tarball"})
    add_urls("https://github.com/OpenVPN/openvpn3.git", {alias = "git"})
    add_versions("tarball:3.11.3", "4a5d18059d6270bd103e290ed4e3bc773e838bc3b22c861408190869fd43074e")
    add_versions("git:3.11.3", "release/3.11.3")

    add_configs("mbedtls", {description = "Use mbed TLS instead of OpenSSL.", default = false, type = "boolean"})
    add_configs("lzo", {description = "Enable LZO compression.", default = false, type = "boolean"})

    add_deps("cmake")
    if not is_subhost("windows") then
        add_deps("pkg-config")
    else
        add_deps("pkgconf")
    end

    add_deps("asio", "fmt", "jsoncpp", "lz4", "xxhash")
    add_defines("ASIO_STANDALONE", "USE_ASIO", "HAVE_LZ4", "HAVE_JSONCPP")
    if is_plat("windows", "msys", "mingw", "cygwin") then
        add_resources("*", "tap-windows6", "https://raw.githubusercontent.com/OpenVPN/tap-windows6/refs/heads/master/src/tap-windows.h", "0b9ea5e4b4dc2c2764fde3383440af9a11a1ead3f2a4bbec674be40da384d10e")
        add_defines("_WIN32_WINNT=0x0600", "TAP_WIN_COMPONENT_ID=tap0901", "_CRT_SECURE_NO_WARNINGS", "ASIO_DISABLE_LOCAL_SOCKETS")
        add_syslinks("fwpuclnt", "iphlpapi", "wininet", "setupapi", "rpcrt4", "wtsapi32", "advapi32", "ole32", "shell32", "ws2_32", "wsock32")
    end

    if is_plat("linux") then
        add_deps("libcap")
    end

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "IOKit", "CoreServices", "SystemConfiguration")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("mbedtls") then
            package:add("deps", "mbedtls")
            package:add("defines", "USE_MBEDTLS")
        else
            package:add("deps", "openssl3")
            package:add("defines", "USE_OPENSSL")
        end
        if package:config("lzo") then
            package:add("deps", "lzo")
            package:add("defines", "HAVE_LZO")
        end
    end)

    on_install("!wasm", function (package)
        os.rmdir("openvpn/omi")
        os.rmdir("openvpn/ovpnagent")
        os.cp("openvpn", package:installdir("include"))
        if package:is_plat("windows", "msys", "mingw", "cygwin") then
            local resdir = package:resourcedir("tap-windows6")
            os.cp(path.join(resdir, "../tap-windows.h"), package:installdir("include"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #ifndef OPENVPN_VERSION
            #error("CHECK FAILED!")
            #endif
        ]]}, {configs = {languages = "c++20"}, includes = "openvpn/common/version.hpp"}))
    end)
