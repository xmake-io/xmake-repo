package("lcc-license-generator")
    set_kind("binary")
    set_homepage("https://github.com/open-license-manager/lcc-license-generator")
    set_description("License generator for open-license-manager")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/open-license-manager/lcc-license-generator.git")
    add_versions("2021.05.27", "816fc5787786541a9074b2a5c3f665d54fac28b0")

    add_configs("openssl", {description = "Use openssl", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("boost", {configs = {
        date_time = true,
        filesystem = true,
        program_options = true,
        system = true,
    }})

    on_load(function (package)
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBoost_USE_STATIC_LIBS=" .. (package:dep("boost"):config("shared") and "OFF" or "ON"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        io.replace("CMakeLists.txt", "unit_test_framework", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("lccgen --help")
    end)
