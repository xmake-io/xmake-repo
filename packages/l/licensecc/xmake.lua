package("licensecc")
    set_homepage("http://open-license-manager.github.io/licensecc/")
    set_description("Software licensing, copy protection in C++. It has few dependencies and it's cross-platform.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/open-license-manager/licensecc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/open-license-manager/licensecc.git")

    add_versions("v2.0.0", "7fc7843f9e6d700135ed1ee63d0f252b820c67da0b0d637d04cd4ea383339145")
    add_patches("v2.0.0", path.join(os.scriptdir(), "patches", "v2.0.0", "fix.patch"), "b26a0f25169247890e7ad68c419ec3c4aae6cbc817db29f4899f97dd3549650d")
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("openssl", {description = "Use openssl", default = false, type = "boolean"})
    add_includedirs("include", "include/licensecc/DEFAULT")
    add_links("licensecc_static")

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt", "crypt32", "ws2_32", "iphlpapi")
    elseif is_plat("linux") then
        add_syslinks("pthread")
        add_deps("valgrind")
    end
    add_deps("cmake")
    add_deps("lcc-license-generator")

    on_load(function (package)
        if not package:is_plat("windows", "mingw") or package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install(function (package)
        local lccgen = package:dep("lcc-license-generator")
        local configs = {"-DBUILD_TESTING=OFF", "-DLCC_LOCATION=" .. lccgen:installdir()}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
        os.trycp(path.join(package:installdir("include"), "licensecc", "DEFAULT", "*.h"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("identify_pc", {includes = "licensecc/licensecc.h"}))
    end)
