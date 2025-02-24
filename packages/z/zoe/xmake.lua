package("zoe")
    set_homepage("https://github.com/winsoft666/zoe")
    set_description("C++ File Download Library.")
    set_license("GPL-3.0")

    add_urls("https://github.com/winsoft666/zoe/archive/refs/tags/$(version).tar.gz",
             "https://github.com/winsoft666/zoe.git")

    add_versions("v3.1", "4b5a0c0cac5fb61846875699cb7e013c84bc33d852041824bde7af80d793f15d")

    add_deps("cmake")
    add_deps("libcurl", "openssl")

    on_install("windows", "mingw", "linux", "macosx", "iphoneos", "cross", "android", function (package)
        local configs = {"-DZOE_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DZOE_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DZOE_USE_STATIC_CRT=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "libcurl"})
        if not package:config("shared") and package:is_plat("windows") then
            package:add("defines", "ZOE_STATIC")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                zoe::Zoe::GlobalInit();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "zoe/zoe.h"}))
    end)
