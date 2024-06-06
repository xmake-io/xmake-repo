package("thorvg")
    set_homepage("https://www.thorvg.org")
    set_description("Thor Vector Graphics is a lightweight portable library used for drawing vector-based scenes and animations including SVG and Lottie. It can be freely utilized across various software platforms and applications to visualize graphical contents.")
    set_license("MIT")

    add_urls("https://github.com/thorvg/thorvg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/thorvg/thorvg.git")

    add_versions("v0.13.6", "f24fd3647e1a309dec00f6455b32258c0dd0e0dbd1133233169467571f188bad")
    add_versions("v0.13.5", "977ed74c3846c9a6acd5765aff776745d40e3c91507b22e51177d59c69afd198")
    add_versions("v0.13.2", "03b5dbb4c73ff221a4bd7243cc0ad377aecff4c3077f5a57ee2902e4122d3218")

    add_configs("engines", {description = "Enable Rasterizer Engine in thorvg", default = {"sw"}, type = "table"})
    add_configs("loaders", {description = "Enable File Loaders", type = "table"})
    add_configs("savers", {description = "Enable File Savers", type = "table"})
    add_configs("tools", {description = "Enable building thorvg tools", type = "table"})
    add_configs("extra", {description = "Enable support for exceptionally advanced features", type = "table"})
    add_configs("threads", {description = "Enable the multi-threading task scheduler in thorvg", default = false, type = "boolean"})
    add_configs("simd", {description = "Enable CPU Vectorization(SIMD) in thorvg", default = false, type = "boolean"})
    add_configs("log", {description = "Enable log message", default = false, type = "boolean"})
    add_configs("c_api", {description = "Enable API bindings", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("meson", "ninja")
    if is_plat("windows") then
        add_deps("pkgconf")
    end

    on_load(function (package)
        import("core.base.hashset")

        local loaders = package:config("loaders")
        if loaders then
            local loaders = hashset.from(loaders)
            if loaders then
                local deps = {jpg = "libjpeg-turbo", png = "libpng", webp = "libwebp"}
                if loaders:has("all") then
                    for _, dep in pairs(deps) do
                        package:add("deps", dep)
                    end
                else
                    for name, dep in pairs(deps) do
                        if loaders:has(name) then
                            package:add("deps", dep)
                        end
                    end
                end
            end
        end
    end)

    on_install("!android", function (package)
        if package:is_plat("mingw") then
            io.replace("src/loaders/svg/tvgSvgLoader.cpp", "float_t", "float", {plain = true})
        end

        local configs = {}
        if package:config("shared") then
            table.insert(configs, "-Ddefault_library=shared")
        else
            table.insert(configs, "-Ddefault_library=static")
            package:add("defines", "TVG_STATIC")
        end

        local loaders = package:config("loaders")
        local savers = package:config("savers")
        local tools = package:config("tools")
        local extra = package:config("extra")
        table.insert(configs, "-Dengines=" .. table.concat(package:config("engines"), ","))
        table.insert(configs, "-Dloaders=" .. (loaders and table.concat(loaders, ",") or ""))
        table.insert(configs, "-Dsavers=" .. (savers and table.concat(savers, ",") or ""))
        table.insert(configs, "-Dtools=" .. (tools and table.concat(tools, ",") or ""))
        table.insert(configs, "-Dextra=" .. (extra and table.concat(extra, ",") or ""))
        if package:config("c_api") then
            table.insert(configs, "-Dbindings=capi")
        end
        table.insert(configs, "-Dthreads=" .. (package:config("threads") and "true" or "false"))
        table.insert(configs, "-Dsimd=" .. (package:config("simd") and "true" or "false"))
        table.insert(configs, "-Dlog=" .. (package:config("log") and "true" or "false"))
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
