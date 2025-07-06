package("argtable3")
    set_homepage("http://www.argtable.org")
    set_description("A single-file, ANSI C, command-line parsing library that parses GNU-style command-line options.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/argtable/argtable3.git")

    add_versions("v3.2.2", "76fd1576e296bd9f93309b2a6e16a3268ad9b8c8")

    add_deps("cmake")

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "argtable3_IMPORTS")
        end

        if package:is_plat("mingw") then
            io.replace("src/version.rc.in", "#include <verrsrc.h>", "", {plain = true})
        end

        if package:version() then
            io.writefile("version.tag", package:version_str() .. ".xmake")
        end

        local configs = {"-DARGTABLE3_ENABLE_TESTS=OFF", "-DARGTABLE3_ENABLE_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DARGTABLE3_ENABLE_ARG_REX_DEBUG=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        os.mkdir(path.join(package:buildir(), "src/pdb"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("arg_parse", {includes = "argtable3.h"}))
    end)
