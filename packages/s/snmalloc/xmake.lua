package("snmalloc")
    set_homepage("https://github.com/microsoft/snmalloc")
    set_description("Message passing based allocator")
    set_license("MIT")

    add_urls("https://github.com/microsoft/snmalloc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/snmalloc.git")

    add_versions("0.7.0", "9e6bd04e58d981218bd5bd3a853d93bbcb1a82dd914f912670f798e011e86746")
    add_versions("0.6.2", "e0486ccf03eac5dd8acbb66ea8ad33bec289572a51614acdf7117397e4f1af8c")
    add_versions("0.6.0", "de1bfb86407d5aac9fdad88319efdd5593ca2f6c61fc13371c4f34aee0b6664f")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})
    add_configs("wait_on_address", {description = "Use wait on address backoff strategy if it is available", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("onecore")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        end
        package:add("defines", "SNMALLOC_USE_WAIT_ON_ADDRESS=" .. (package:config("wait_on_address") and "1" or "0"))
    end)

    on_install("!wasm and !iphoneos", function (package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})

        local configs = {"-DSNMALLOC_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSNMALLOC_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DSNMALLOC_IPO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DSNMALLOC_HEADER_ONLY_LIBRARY=" .. (package:config("header_only") and "ON" or "OFF"))
        table.insert(configs, "-DSNMALLOC_ENABLE_WAIT_ON_ADDRESS=" .. (package:config("wait_on_address") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        os.cp("src/snmalloc", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("snmalloc::DefaultPal::message(\"\")",
            {includes = "snmalloc/snmalloc.h", configs = {languages = "c++20", cxflags = "-mcx16"}}))
    end)
