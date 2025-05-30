package("glosshook")
    set_homepage("https://github.com/XMDS/GlossHook")
    set_description("A simple android NativeHook library.")
    set_license("MIT")

    add_urls("https://github.com/XMDS/GlossHook/archive/refs/tags/$(version).tar.gz",
             "https://github.com/XMDS/GlossHook.git")

    add_versions("v1.9.5", "a80995c625a99bf5cd67539838d1fd487366c89e8a61c5838165da11c46de8f1")

    add_deps("xdl")

    on_install("android", function (package)
        os.cp("GlossHook/include", package:installdir())
        if package:config("shared") then
            if package:check_sizeof("void*") == "4" then
                os.cp("GlossHook/lib/ARM/libGlossHook.so", package:installdir("lib"))
            else
                os.cp("GlossHook/lib/ARM64/libGlossHook.so", package:installdir("lib"))
            end
        else
            if package:check_sizeof("void*") == "4" then
                os.cp("GlossHook/lib/ARM/libGlossHook.a", package:installdir("lib"))
            else
                os.cp("GlossHook/lib/ARM64/libGlossHook.a", package:installdir("lib"))
            end
        end        
        os.cp("GlossHook/include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("GlossOpen", {includes = "Gloss.h"}))
    end)
