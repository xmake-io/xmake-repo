package("liblsl")
    set_homepage("https://github.com/sccn/liblsl")
    set_description("C++ lsl library for multi-modal time-synched data transmission over the local network.")
    set_license("MIT")

    add_urls("https://github.com/sccn/liblsl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sccn/liblsl.git")
    add_versions("v1.17.5", "6f1f5a3fc4c4a162c86ced19c75d13a81d8ebe1f819c50caf257b1ee0b401d1a")

    add_deps("cmake")

    on_load(function (package)
        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread")
        elseif package:is_plat("windows") then
            package:add("syslinks", "ws2_32")
        end

        if not package:config("shared") then
            package:add("defines", "LIBLSL_STATIC")
        end
    end)

    on_install("linux", "macosx", "windows", "bsd", function (package)
        local configs = {
            "-DLSL_UNITTESTS=OFF",
            "-DLSL_TOOLS=OFF",
            "-DLSL_INSTALL=ON",
            "-DLSL_BUNDLED_BOOST=ON",
            "-DLSL_BUNDLED_PUGIXML=ON",
            "-DLSL_FRAMEWORK=OFF",
            "-DLSL_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON")
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lsl_local_clock", {includes = "lsl_c.h"}))
    end)
