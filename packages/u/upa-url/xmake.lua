package("upa-url")
    set_homepage("https://upa-url.github.io/docs/")
    set_description("An implementation of the WHATWG URL Standard in C++")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/upa-url/upa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/upa-url/upa.git", {submodules = false})

    add_versions("v1.0.2", "d08a724c1868530b1c0b89ebeaaf2d654f7e6489c968a3dc2255b1f21ddc94e0")
    add_versions("v1.0.1", "458d49c1e84063a2e38b40f5dae5ba01e618e7fba29550f9cc01bf10d04ff7a1")
    add_versions("v1.0.0", "9ad14357c177f7c038a447996a065995e074eb5447015467687726c5d221b5f4")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                set_languages("c++11")
                target("upa_url")
                    set_kind("$(kind)")
                    add_files("src/*.cpp")
                    add_includedirs("include")
                    add_headerfiles("include/(upa/*.h)")
                    if is_plat("windows") and is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
            ]])
            import("package.tools.xmake").install(package)
        else
            io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
    
            local configs = {"-DURL_BUILD_TESTS=OFF", "-DUPA_BUILD_TESTS=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DUPA_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                upa::url url{"https://xmake.io/"};
            }
        ]]}, {configs = {languages = "c++11"}, includes = "upa/url.h"}))
    end)
