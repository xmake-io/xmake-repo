package("libwebp")

    set_homepage("https://chromium.googlesource.com/webm/libwebp/")
    set_description("Library to encode and decode images in WebP format.")
    set_license("BSD-3-Clause")

    local commits = {["1.1.0"] = "d7844e9762b61c9638c263657bd49e1690184832"}
    add_urls("https://github.com/webmproject/libwebp/archive/v$(version).tar.gz", {alias = "github"})
    add_urls("https://chromium.googlesource.com/webm/libwebp/+archive/$(version).tar.gz", {alias = "google", version = function (version) return commits[tostring(version)] end})
    add_versions("github:1.1.0", "424faab60a14cb92c2a062733b6977b4cc1e875a6398887c5911b3a1a6c56c51")
    add_versions("google:1.1.0", "538fa4368f303251f7a672db5bf9970089493fab58c0d457e31a89703d9a786b")

    add_configs("anim_utils",     { description = "Build animation utilities.", default = false, type = "boolean"})
    add_configs("cwebp",          { description = "Build the cwebp command line tool.", default = false, type = "boolean"})
    add_configs("dwebp",          { description = "Build the dwebp command line tool.", default = false, type = "boolean"})
    add_configs("gif2webp",       { description = "Build the gif2webp conversion tool.", default = false, type = "boolean"})
    add_configs("img2webp",       { description = "Build the img2webp animation tool.", default = false, type = "boolean"})
    add_configs("vwebp",          { description = "Build the vwebp viewer tool.", default = false, type = "boolean"})
    add_configs("webpinfo",       { description = "Build the webpinfo command line tool.", default = false, type = "boolean"})
    add_configs("webpmux",        { description = "Build the webpmux command line tool.", default = false, type = "boolean"})
    add_configs("extras",         { description = "Build extras.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("libpng", "libjpeg", "libtiff", "giflib")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DWEBP_BUILD_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        local cxflags
        if package:is_plat("windows") and package:config("shared") then
            if xmake.version():ge("2.5.1") then
                cxflags = "-DWEBP_EXTERN=__declspec(dllexport)"
            else
                cxflags = package:configs().cxflags or {}
                table.insert(cxflags, "-DWEBP_EXTERN=__declspec(dllexport)")
                package:configs().cxflags = cxflags
            end
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("WebPGetEncoderVersion", {includes = "webp/encode.h"}))
    end)
