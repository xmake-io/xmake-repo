package("thorvg")
    set_homepage("https://www.thorvg.org")
    set_description("Thor Vector Graphics is a lightweight portable library used for drawing vector-based scenes and animations including SVG and Lottie. It can be freely utilized across various software platforms and applications to visualize graphical contents.")
    set_license("MIT")

    add_urls("https://github.com/thorvg/thorvg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/thorvg/thorvg.git")

    add_versions("v0.13.2", "03b5dbb4c73ff221a4bd7243cc0ad377aecff4c3077f5a57ee2902e4122d3218")

    add_configs("c_api", {description = "Enable API bindings", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("meson", "ninja")

    on_install("!android", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "-Ddefault_library=shared")
        else
            table.insert(configs, "-Ddefault_library=static")
            package:add("defines", "TVG_STATIC")
        end
        if package:config("c_api") then
            table.insert(configs, "-Dbindings=capi")
        end
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <thorvg.h>
            void test() {
                tvg::Initializer::init(tvg::CanvasEngine::Sw, 0);
            }
        ]]}, {configs = {languages = "c++14"}}))

        if package:config("c_api") then
            assert(package:has_cxxfuncs("tvg_engine_init", {includes = "thorvg_capi.h"}))
        end
    end)
