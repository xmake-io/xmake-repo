package("wingetopt")
    set_homepage("https://github.com/alex85k/wingetopt")
    set_description("getopt library for Windows compilers")

    add_urls("https://github.com/alex85k/wingetopt.git")

    add_versions("2025.12.01", "98ea94f3d77890678da28230aa156b225cc14974")
    add_versions("2023.10.29", "e8531ed21b44f5a723c1dd700701b2a58ce3ea01")

    add_deps("cmake")

    on_install("windows", "mingw", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "WINGETOPT_SHARED_LIB")
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("getopt", {includes = "getopt.h"}))
    end)
