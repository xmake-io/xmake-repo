package("libwebp")

    set_homepage("https://chromium.googlesource.com/webm/libwebp/")
    set_description("Library to encode and decode images in WebP format.")
    set_license("BSD-3-Clause")

    local commits = {["1.1.0"] = "d7844e9762b61c9638c263657bd49e1690184832"}
    add_urls("https://github.com/webmproject/libwebp/archive/v$(version).tar.gz", {alias = "github"})
    add_urls("https://chromium.googlesource.com/webm/libwebp/+archive/$(version).tar.gz", {alias = "google", version = function (version) return commits[tostring(version)] end})
    add_versions("github:1.1.0", "424faab60a14cb92c2a062733b6977b4cc1e875a6398887c5911b3a1a6c56c51")
    add_versions("google:1.1.0", "538fa4368f303251f7a672db5bf9970089493fab58c0d457e31a89703d9a786b")

    add_deps("libpng", "libjpeg", "libtiff", "giflib")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    if is_plat("linux", "macosx", "bsd") then
        add_deps("autoconf", "automake")
    end

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows", function (package)
        local configs = {"-f", "Makefile.vc"}
        local cfg = (package:debug() and "debug" or "release") .. "-" .. (package:config("shared") and "dynamic" or "static")
        local arch = package:arch()
        table.insert(configs, "CFG=" .. cfg)
        table.insert(configs, "RTLIBCFG=" .. (package:config("vs_runtime"):startswith("MT") and "static" or "dynamic"))
        table.insert(configs, "ARCH=" .. arch)
        import("package.tools.nmake").build(package, configs)
        local base = path.join("..", "obj", cfg, arch)
        os.cp(path.join(base, "lib"), package:installdir())
        os.cp(path.join("src", "webp"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("WebPGetEncoderVersion", {includes = "webp/encode.h"}))
    end)
