package("glosshook")
    set_homepage("https://github.com/XMDS/GlossHook")
    set_description("A simple android NativeHook library.")
    set_license("MIT")

    add_urls("https://github.com/XMDS/GlossHook/releases/download/$(version)", {version = function (version)
        return version .. "/GlossHook." .. version:major() .. "." .. version:minor() .. "." .. version:patch() .. ".zip"
    end})

    add_versions("v1.9.5", "3e964dc5d3dc8f49647a3fc2415ac8d0978fde508579db573df9d4b0a4e923bf")

    add_deps("xdl")

    on_install("android", function (package)
        if package:config("shared") then
            if package:check_sizeof("void*") == "4" then
                os.cp("lib/ARM/libGlossHook.so", package:installdir("lib"))
            else
                os.cp("lib/ARM64/libGlossHook.so", package:installdir("lib"))
            end
        else
            if package:check_sizeof("void*") == "4" then
                os.cp("lib/ARM/libGlossHook.a", package:installdir("lib"))
            else
                os.cp("lib/ARM64/libGlossHook.a", package:installdir("lib"))
            end
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("GlossOpen", {includes = "Gloss.h"}))
    end)
