package("pcre2")

    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    set_urls("https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$(version)/pcre2-$(version).tar.gz")
    add_versions("10.40", "ded42661cab30ada2e72ebff9e725e745b4b16ce831993635136f2ef86177724")
    add_versions("10.39", "0781bd2536ef5279b1943471fdcdbd9961a2845e1d2c9ad849b9bd98ba1a9bd4")

    add_deps("cmake")

    if not is_plat("iphoneos") then
        add_configs("jit", {description = "Enable jit.", default = not is_plat("wasm"), type = "boolean"})
    end
    add_configs("bitwidth", {description = "Set the code unit width.", default = "8", values = {"8", "16", "32"}})

    on_load(function (package)
        local bitwidth = package:config("bitwidth") or "8"
        local suffix = ""
        if package:is_plat("windows") and package:debug() then
            suffix = "d"
        end
        if package:version():ge("10.39") and package:is_plat("windows") and not package:config("shared") then
            package:add("links", "pcre2-" .. bitwidth .. "-static" .. suffix)
        else
            package:add("links", "pcre2-" .. bitwidth .. suffix)
        end
        package:add("defines", "PCRE2_CODE_UNIT_WIDTH=" .. bitwidth)
        if not package:config("shared") then
            package:add("defines", "PCRE2_STATIC")
        end
    end)

    on_install(function (package)
        if package:version():lt("10.21") then
            io.replace("CMakeLists.txt", [[SET(CMAKE_C_FLAGS -I${PROJECT_SOURCE_DIR}/src)]], [[SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${PROJECT_SOURCE_DIR}/src")]], {plain = true})
        end
        local configs = {"-DPCRE2_BUILD_TESTS=OFF", "-DPCRE2_BUILD_PCRE2GREP=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPCRE2_SUPPORT_JIT=" .. (package:config("jit") and "ON" or "OFF"))
        local bitwidth = package:config("bitwidth") or "8"
        if bitwidth ~= "8" then
            table.insert(configs, "-DPCRE2_BUILD_PCRE2_8=OFF")
            table.insert(configs, "-DPCRE2_BUILD_PCRE2_" .. bitwidth .. "=ON")
        end
        if package:debug() then
            table.insert(configs, "-DPCRE2_DEBUG=ON")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DPCRE2_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pcre2_compile", {includes = "pcre2.h"}))
    end)
