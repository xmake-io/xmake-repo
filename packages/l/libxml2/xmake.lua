package("libxml2")
    set_homepage("http://xmlsoft.org/")
    set_description("The XML C parser and toolkit of Gnome.")
    set_license("MIT")

    add_urls("https://gitlab.gnome.org/GNOME/libxml2/-/archive/$(version)/libxml2-$(version).tar.bz2",
             "https://gitlab.gnome.org/GNOME/libxml2.git",
             "https://github.com/GNOME/libxml2.git")

    add_versions("v2.13.4", "ba783b43e8b3475cbd2b1ef40474da6a4465105ee9818d76cd3ac7863550afce")
    add_versions("v2.13.2", "5091cf2767c3f7ba08bf59fbe85b01db36ca21abdcb37deea964fcb26a4391fb")
    add_versions("v2.12.9", "3cd02671b20954865f5b3e90f192d8cc4d815b2362c2ff9a0b450b41648dac58")
    add_versions("v2.11.9", "b9ed243467f82306da608a7a735ed55d90c7aaab0d3c6cf61284c43daa77cfee")

    includes(path.join(os.scriptdir(), "configs.lua"))
    for name, desc in pairs(get_libxml2_configs()) do
        add_configs(name, {description = desc[1], default = desc[2], type = "boolean"})
    end
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    add_configs("all", {description = "Enable all configs, exclude python", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32", "bcrypt")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    if is_plat("linux") then
        add_extsources("pkgconfig::libxml-2.0", "apt::libxml2-dev", "pacman::libxml2")
    end

    add_includedirs("include/libxml2")

    add_deps("cmake")

    if on_check then
        on_check("iphoneos", function (package)
            if not package:gitref() then
                raise("All version unsupported now. see https://gitlab.gnome.org/GNOME/libxml2/-/issues/774\nYou can use `libxml2 master` branch to build or open a pull request to patch it.")
            end
        end)
    end

    on_load(function (package)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "LIBXML_STATIC")
        end

        if package:config("all") then
            for name, _ in pairs(import("configs").get_libxml2_configs()) do
                if name ~= "python" then
                    package:config_set(name, true)
                end
            end
        end

        if package:config("threads") and package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread")
        end

        if package:config("tools") then
            package:config_set("programs", true)
            package:addenv("PATH", "bin")
        end

        if package:config("iconv") then
            package:add("deps", "libiconv")
        end
        if package:config("icu") then
            package:add("deps", "icu4c")
        end
        if package:config("lzma") then
            package:add("deps", "xz")
        end
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("readline") and package:is_plat("linux", "macosx") then
            package:add("deps", "readline")
        end
        if package:config("python") then
            assert(package:config("shared"), "package(libxml2) python interface require shared lib")
            if package:is_cross() then
                raise("libxml2 python interface does not support cross-compilation")
            end
            if not package:config("iconv") then
                raise("libxml2 python interface requires iconv to be enabled")
            end
            package:add("deps", "python 3.x")
            package:addenv("PYTHONPATH", package:installdir("python"))
        end
    end)

    on_install(function (package)
        local configs = {"-DLIBXML2_WITH_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, _ in pairs(import("configs").get_libxml2_configs()) do
            local enabled = (package:config(name) and "ON" or "OFF")
            table.insert(configs, format("-DLIBXML2_WITH_%s=%s", name:upper(), enabled))
        end

        local opt = {}
        local lzma = package:dep("xz")
        if lzma and not lzma:config("shared") then
            opt.cxflags = "-DLZMA_API_STATIC"
        end
        import("package.tools.cmake").install(package, configs, opt)
        if package:is_plat("windows") then
            local libfiles = os.files(package:installdir("lib/*xml2*.lib"))[1]
            local pc = package:installdir("lib/pkgconfig/libxml-2.0.pc")
            io.replace(pc, "-lxml2", "-l" .. path.basename(libfiles), {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xmlInitParser", {includes = "libxml/parser.h"}))
        if package:config("python") then
            if package:is_plat("windows") then
                os.vrun([[python -c "import libxml2"]])
            else
                os.vrun([[python3 -c "import libxml2"]])
            end
        end
    end)
