package("lcc-license-generator")
    set_kind("binary")
    set_homepage("https://github.com/open-license-manager/lcc-license-generator")
    set_description("License generator for open-license-manager")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/open-license-manager/lcc-license-generator.git")
    add_versions("2021.05.27", "816fc5787786541a9074b2a5c3f665d54fac28b0")
    add_patches("2021.05.27", path.join(os.scriptdir(), "patches", "2021.05.27", "fix.patch"), "94d922834ed4f34ab13e0d7b800e4684e638a5956d3991d1aa58bd502b00c3ca")
    add_configs("openssl", {description = "Use openssl", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("boost", {configs = {
        date_time = true,
        filesystem = true,
        program_options = true,
        system = true,
    }})

    on_load(function (package)
        if not package:is_plat("windows", "mingw") or package:config("openssl") then
            package:add("deps", "openssl3")
        end
    end)

    on_install("@windows", "@linux", "@bsd", "@msys", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBoost_USE_STATIC_LIBS=" .. (package:dep("boost"):config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end
        if package:is_plat("windows", "mingw") and not package:config("openssl") then
            table.insert(configs, "-DUSE_OPENSSL=OFF")
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=ON")
        else
            table.insert(configs, "-DUSE_OPENSSL=ON")
            table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_OpenSSL=OFF")
            local openssl = package:dep("openssl3") or package:dep("openssl")
            if openssl then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("lccgen --help")
    end)
