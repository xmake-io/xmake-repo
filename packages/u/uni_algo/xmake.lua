package("uni_algo")

    set_homepage("https://github.com/uni-algo/uni-algo/")
    set_description("Unicode Algorithms Implementation for C/C++")
    set_license("MIT")

    add_urls("https://github.com/uni-algo/uni-algo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uni-algo/uni-algo.git")
    add_versions("v0.7.1", "9ff1f03d6ffd81df7a2a21df353502db55d198a940da0aef0546b37ca934fdfb")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        if package:config("header_only") then
            os.cp("include", package:installdir())
            package:add("defines", "UNI_ALGO_STATIC_DATA")
        else
            local configs = {"-DDOWNLOAD_UNICODE_TEST_FILES=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
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
