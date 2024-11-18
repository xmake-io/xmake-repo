package("limonp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/yanyiwu/limonp")
    set_description("C++ headers(hpp) library with Python style.")
    set_license("MIT")

    add_urls("https://github.com/yanyiwu/limonp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yanyiwu/limonp.git")

    add_versions("v1.0.0", "57c088a10ceda774e05281b1fc7779455af2cc824969e331874871822452e24f")
    add_versions("v0.9.0", "92d90b262ab2e3375dd386731deeb028f88ee7d07d0695d53d10bef6887d2f5f")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY(test)", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                limonp::StringFormat("format");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "limonp/StringUtil.hpp"}))
    end)
