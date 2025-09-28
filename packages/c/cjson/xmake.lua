package("cjson")
    set_homepage("https://github.com/DaveGamble/cJSON")
    set_description("Ultralightweight JSON parser in ANSI C.")
    set_license("MIT")

    set_urls("https://github.com/DaveGamble/cJSON/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DaveGamble/cJSON.git")

    add_versions("v1.7.19", "7fa616e3046edfa7a28a32d5f9eacfd23f92900fe1f8ccd988c1662f30454562")
    add_versions("v1.7.18", "3aa806844a03442c00769b83e99970be70fbef03735ff898f4811dd03b9f5ee5")
    add_versions("v1.7.15", "5308fd4bd90cef7aa060558514de6a1a4a0819974a26e6ed13973c5f624c24b2")

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("windows") then
            if package:config("shared") then
                package:add("defines", "CJSON_IMPORT_SYMBOLS")
            else
                package:add("defines", "CJSON_HIDE_SYMBOLS")
            end
        end

        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        local configs = {"-DENABLE_CJSON_TEST=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "cjson.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cJSON_malloc", {includes = "cjson/cJSON.h"}))
    end)
