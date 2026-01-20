package("bzip2")
    set_homepage("https://sourceware.org/bzip2/")
    set_description("Freely available, patent free, high-quality data compressor.")

    add_urls("https://sourceware.org/pub/bzip2/bzip2-$(version).tar.gz",
             "https://pub.sortix.org/mirror/bzip2/bzip2-$(version).tar.gz")
    add_versions("1.0.8", "ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::bzip2")
    elseif is_plat("linux") then
        add_extsources("pacman::bzip2", "apt::libbz2-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::bzip2")
    end

    on_load(function (package)
        -- @see https://github.com/xmake-io/xmake-repo/pull/8179#issuecomment-3327113818, patches from msys2/MINGW-packages.
        if package:is_plat("msys", "mingw", "cygwin") then
            package:add("patches", "*", "patches/cygming.patch", "7e67f77172b19f3e6c1f0875b1d3e9cb79211f8e1c752794ef9afd3704f928cf")
            package:add("patches", "*", "patches/show-progress.patch", "57f35bd9ef9113629c1d0ab6bcbbb7c0df0f7f4402ba0dccada32aa1cfe838f5")
        end
    end)

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
            os.vrun("bunzip2 --help")
            os.vrun("bzcat --help")
            os.vrun("bzip2 --help")
        end

        assert(package:has_cfuncs("BZ2_bzCompressInit", {includes = "bzlib.h"}))
    end)
