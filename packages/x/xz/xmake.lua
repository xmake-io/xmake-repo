package("xz")

    set_homepage("https://tukaani.org/xz/")
    set_description("General-purpose data compression with high compression ratio.")

    set_urls("https://downloads.sourceforge.net/project/lzmautils/xz-$(version).tar.gz",
             "https://tukaani.org/xz/xz-$(version).tar.gz")
    add_versions("5.2.5", "f6f4910fd033078738bd82bfba4f49219d03b17eb0794eb91efbae419f4aba10")

    on_load(function (package)
        if is_plat(os.host()) then
            package:addenv("PATH", "bin")
        end
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "LZMA_API_STATIC")
        end
    end)

    on_install("windows", "mingw@windows", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_install("macosx", "linux", "mingw@linux,macosx", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lzma_code", {includes = "lzma.h"}))
    end)
