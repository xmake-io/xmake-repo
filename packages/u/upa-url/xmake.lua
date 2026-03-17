package("upa-url")
    set_homepage("https://upa-url.github.io/docs/")
    set_description("An implementation of the WHATWG URL Standard in C++")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/upa-url/upa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/upa-url/upa.git", {submodules = false})

    add_versions("v2.4.0", "97a7ddf56c8b65e8b54027d01acfb4fe7b2f0f1f16ce5023d12ce5a5539718ff")
    add_versions("v2.3.0", "707b487534c1cb2be6bc180249b6c0fd7947758a4bca76754c0afdbda462bdba")
    add_versions("v2.2.0", "7b6d5e5774d0264ef2be0782ec3548e191ef113b34983323791a914a00de0d3a")
    add_versions("v2.1.0", "4a5edae83dc5c9a2aacfdb4720d6bce3ceff5edfb19213615b1e95a44a7793fe")
    add_versions("v2.0.0", "50e0d7c9cad853c794f9b12aded960dbdcf3ba6baa8bc9896da52fe526cc014e")
    add_versions("v1.2.0", "5d8a251ffd708a14f9faf2ea29dae934cb4b29c5473bd2bcf2e3d16eccaeacb7")
    add_versions("v1.0.2", "d08a724c1868530b1c0b89ebeaaf2d654f7e6489c968a3dc2255b1f21ddc94e0")
    add_versions("v1.0.1", "458d49c1e84063a2e38b40f5dae5ba01e618e7fba29550f9cc01bf10d04ff7a1")
    add_versions("v1.0.0", "9ad14357c177f7c038a447996a065995e074eb5447015467687726c5d221b5f4")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:config_set("cmake", false)
        end
        
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
    
            local configs = {"-DURL_BUILD_TESTS=OFF", "-DUPA_BUILD_TESTS=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DUPA_BUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                set_languages("c++17")
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
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                upa::url url{"https://xmake.io/"};
            }
        ]]}, {configs = {languages = "c++17"}, includes = "upa/url.h"}))
    end)
