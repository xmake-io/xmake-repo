package("clap")
    set_kind("library", {headeronly = true})
    set_homepage("https://cleveraudio.org/")
    set_description("cross plat Audio Plugin API")
    
    add_urls("https://github.com/free-audio/clap/archive/refs/tags/$(version).zip")

    add_versions("1.2.10","e3016e90da0cba5d194e2c565a4eed14325091938560394e636ba4e5230d7cd0")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        import("package.tools.cmake").install(package, configs)
    end)
    
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
               clap_plugin_render_mode renderMode = CLAP_RENDER_REALTIME;
            }
        ]]}, {configs = {languages = "c++20"}, includes = "clap/clap.h"}))
    end)
