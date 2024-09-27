package("licensecc")
    set_homepage("http://open-license-manager.github.io/licensecc/")
    set_description("Software licensing, copy protection in C++. It has few dependencies and it's cross-platform.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/open-license-manager/licensecc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/open-license-manager/licensecc.git")

    add_versions("v2.0.0", "7fc7843f9e6d700135ed1ee63d0f252b820c67da0b0d637d04cd4ea383339145")

    add_configs("openssl", {description = "Use openssl", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt", "crypt32", "ws2_32", "iphlpapi")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("lcc-license-generator")

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install(function (package)
        local cmakedir = package:dep("lcc-license-generator"):installdir("cmake")
        local configs = {"-DBUILD_TESTING=OFF", "-DLCC_LOCATION=" .. cmakedir}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBoost_USE_STATIC_LIBS=" .. (package:dep("boost"):config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("identify_pc", {includes = "licensecc/licensecc.h"}))
    end)
