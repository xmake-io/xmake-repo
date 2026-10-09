package("licensecc")
    set_homepage("http://open-license-manager.github.io/licensecc/")
    set_description("Software licensing, copy protection in C++. It has few dependencies and it's cross-platform.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/open-license-manager/licensecc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/open-license-manager/licensecc.git")

    add_versions("v2.0.0", "7fc7843f9e6d700135ed1ee63d0f252b820c67da0b0d637d04cd4ea383339145")
    add_patches("v2.0.0", path.join(os.scriptdir(), "patches", "v2.0.0", "fix.patch"), "95e907848eca2f5d8f7338eaf20007a8b1adab35dae8b25acbdf860c5a405c59")
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("openssl", {description = "Use openssl", default = false, type = "boolean"})
    add_includedirs("include", "include/licensecc/DEFAULT")
    add_links("licensecc_static")

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt", "crypt32", "ws2_32", "iphlpapi", "advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end
    add_deps("cmake")
    add_deps("lcc-license-generator")

    if on_check then
        on_check("mingw", function (package)
            if is_subhost("macosx") then
                raise("package(licensecc): does not support mingw@macosx")
            end
        end)
        on_check("android", function (package)
            if not package:has_cxxfuncs("freeifaddrs", {includes = "ifaddrs.h"}) then
                raise("package(licensecc): does not support android build without freeifaddrs function.")
            end
        end)
    end

    on_load(function (package)
        if not package:is_plat("windows", "mingw") or package:config("openssl") then
            package:add("deps", "openssl3")
        end
    end)

    on_install("!macosx and !iphoneos and !wasm", function (package)
        if package:is_plat("bsd") then
            os.cp(path.join(package:scriptdir(), "port", "mntent.h"), "include/mntent.h")
        end
        local lccgen = package:dep("lcc-license-generator")
        local configs = {"-DBUILD_TESTING=OFF", "-DLCC_LOCATION=" .. lccgen:installdir()}
        local lccgen_exe = path.join(lccgen:installdir("bin"), "lccgen" .. (package:is_plat("windows", "mingw") and ".exe" or ""))
        if os.isfile(lccgen_exe) then
            table.insert(configs, "-DLCC_EXECUTABLE=" .. lccgen_exe)
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end
        if package:is_plat("windows", "mingw") and not package:config("openssl") then
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=ON")
        else
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=OFF")
            local openssl = package:dep("openssl3") or package:dep("openssl")
            if openssl then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end
        import("package.tools.cmake").install(package, configs)
        os.trycp(path.join(package:installdir("include"), "licensecc", "DEFAULT", "*.h"), package:installdir("include"))
        if package:is_plat("bsd") then
            os.tryrm(path.join(package:installdir("include"), "mntent.h"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("identify_pc", {includes = "licensecc/licensecc.h"}))
    end)
