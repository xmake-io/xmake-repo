package("bzip2")
    set_homepage("https://sourceware.org/bzip2/")
    set_description("Freely available, patent free, high-quality data compressor.")

    add_urls("https://sourceware.org/pub/bzip2/bzip2-$(version).tar.gz")
    add_versions("1.0.8", "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::bzip2")
    elseif is_plat("linux") then
        add_extsources("pacman::bzip2", "apt::libbz2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::bzip2")
    end

    on_install(function (package)
        local configs = {}
        configs.enable_tools = not package:is_plat("wasm")
        if not package:is_plat("iphoneos", "android") then
            package:addenv("PATH", "bin")
        end

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        if not package:is_cross() then
            local envs
            if package:is_plat("windows") then
                import("core.tool.toolchain")
                local msvc = toolchain.load("msvc")
                if msvc and msvc:check() then
                    envs = msvc:runenvs()
                end
            elseif package:is_plat("mingw") then
                import("core.tool.toolchain")
                local mingw = toolchain.load("mingw")
                if mingw and mingw:check() then
                    envs = mingw:runenvs()
                end
            end
            os.vrunv("bunzip2", {"--help"}, {envs = envs})
            os.vrunv("bzcat", {"--help"}, {envs = envs})
            os.vrunv("bzip2", {"--help"}, {envs = envs})
        end

        assert(package:has_cfuncs("BZ2_bzCompressInit", {includes = "bzlib.h"}))
    end)
