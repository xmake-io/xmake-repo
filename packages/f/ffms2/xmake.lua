package("ffms2")
    set_homepage("https://github.com/FFMS/ffms2")
    set_description("An FFmpeg based source library and Avisynth/VapourSynth plugin for easy frame accurate access")
    set_license("MIT")

    add_urls("https://github.com/FFMS/ffms2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/FFMS/ffms2.git")

    add_versions("5.0", "7770af0bbc0063f9580a6a5c8e7c51f1788f171d7da0b352e48a1e60943a8c3c")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("zlib", "ffmpeg")

    on_check("windows|arm64", function (package)
        if not package:is_cross() then
            raise("package(ffms2) dep(ffmpeg) unsupported windows arm64 native build, because it require arm64 msys2")
        end
    end)

    on_install("windows", "mingw@windows,linux,cygwin,msys", "linux", "macosx", "android", "iphoneos", function (package)
        if not package:config("shared") then
            package:add("defines", "FFMS_STATIC")
        end

        io.writefile("xmake.lua", [[
            option("tools", {default = false})
            add_rules("mode.debug", "mode.release")

            add_languages("c++11")

            add_requires("zlib", "ffmpeg")

            target("ffms2")
                set_kind("$(kind)")
                add_includedirs("include", {public = true})
                add_files("src/core/*.cpp")
                add_headerfiles("include/*.h")

                if is_kind("static") then
                    add_defines("FFMS_STATIC", {public = true})
                elseif is_kind("shared") then
                    add_defines("FFMS_EXPORTS")
                end

                add_packages("zlib")
                add_packages("ffmpeg", {public = true})

            target("ffmsindex")
                set_enabled(has_config("tools"))
                set_kind("binary")
                add_files("src/index/ffmsindex.cpp", "src/index/ffmsindex.manifest")
                add_deps("ffms2")
        ]])
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FFMS_Init", {includes = "ffms.h"}))
    end)
