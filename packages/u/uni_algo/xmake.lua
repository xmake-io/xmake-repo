package("uni_algo")
    set_homepage("https://github.com/uni-algo/uni-algo/")
    set_description("Unicode Algorithms Implementation for C/C++")
    set_license("MIT")

    add_urls("https://github.com/uni-algo/uni-algo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uni-algo/uni-algo.git")

    add_versions("v0.7.1", "9ff1f03d6ffd81df7a2a21df353502db55d198a940da0aef0546b37ca934fdfb")
    add_versions("v0.8.0", "657f124f4fb4705f948e9c0835ec88484ee4745d7b19cb2ddb772119a7ea024e")
    add_versions("v0.8.1", "11192280fa435a9d68131d5368d2b314201d7089e6d2f38f29a8591c9aafa776")
    add_versions("v0.8.2", "c0dab8ae1dbbab3e33b0c5bb512e927badb57f53e7ee96517c1dfd2e078b7669")
    add_versions("v1.0.0", "a59d61cd4a4fff08672831c7e5a8c204bb6e96c21506b6471771c01b38958a15")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
            package:add("defines", "UNI_ALGO_STATIC_DATA")
        end
    end)

    on_install(function (package)
        local configs = {"-DDOWNLOAD_UNICODE_TEST_FILES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUNI_ALGO_HEADER_ONLY=" .. (package:config("header_only") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "uni_algo/conv.h"

            void test() {
                std::string str8 = una::utf16to8(u"Te\xD800st");
                assert(str8 == "Te\xEF\xBF\xBDst");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
