package("notcurses")
    set_homepage("https://nick-black.com/dankwiki/index.php/Notcurses")
    set_description("blingful character graphics/TUI library. definitely not curses.")

    add_urls("https://github.com/dankamongmen/notcurses/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dankamongmen/notcurses.git")

    add_versions("v3.0.17", "b0fbe824984fe25b5a16770dbd00b85d44db5d09cc35bd881b95335d0db53128")

    add_configs("libdeflate", {description = "Use libdeflate instead of libz", default = false, type = "boolean"})
    add_configs("multimedia", {description = "Multimedia engine", default = "none", type = "string", values = {"ffmpeg", "oiio", "none"}})
    add_configs("qrcodegen", {description = "Enable QR code support", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("libunistring")

    on_load(function (package)
        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread", "m", "rt")
        elseif package:is_plat("windows") then
            package:add("syslinks", "wsock32", "ws2_32", "secur32")
        end

        if not is_subhost("windows") then
            package:add("deps", "pkg-config")
        else
            package:add("deps", "pkgconf")
        end
        if package:is_plat("linux") then
            package:add("deps", "gpm")
        end

        if package:config("libdeflate") then
            package:add("deps", "libdeflate")
        else
            package:add("deps", "zlib")
        end

        local multimedia = package:config("multimedia")
        if multimedia == "ffmpeg" then
            package:add("deps", "ffmpeg")
        elseif multimedia == "oiio" then
            package:add("deps", "openimageio")
        end

        if package:config("qrcodegen") then
            package:add("deps", "qr-code-generator-c")
        end
    end)

    on_install(function (package)
        local configs = {"-DUSE_PANDOC=OFF", "-DBUILD_TESTING=OFF", "-DUSE_DOCTEST=OFF", "-DUSE_POC=OFF","-DBUILD_EXECUTABLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DUSE_DEFLATE=" .. (package:config("libdeflate") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MULTIMEDIA=" .. (package:config("multimedia")))
        table.insert(configs, "-DUSE_QRCODEGEN=" .. (package:config("qrcodegen") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("notcurses_version()", {includes = "notcurses/notcurses.h"}))
    end)
