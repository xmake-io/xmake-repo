package("dlss")
    set_homepage("https://github.com/NVIDIA/DLSS")
    set_description("NVIDIA DLSS is a new and improved deep learning neural network that boosts frame rates and generates beautiful, sharp images for your games")
    set_license("NVIDIA RTX SDKs")

    add_urls("https://github.com/NVIDIA/DLSS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/DLSS.git")

    add_versions("v3.7.20", "904d771551526dd6aa458f0db7b85fe4abb8f49ce0307d377e8da089628bf9ec")

    on_install("windows|x64", "linux|x86_64", function (package)
        os.cp("include", package:installdir())
        if is_plat("windows") then
            os.cp("lib/Windows_x86_64/x86_64/*.lib", package:installdir("lib"))
            if package:is_debug() then
                os.cp("lib/Windows_x86_64/dev/*", package:installdir("bin"))
            else
                os.cp("lib/Windows_x86_64/rel/*", package:installdir("bin"))
            end
        else
            package:add("syslinks", "dl")
            os.cp("lib/Linux_x86_64/*.a", package:installdir("lib"))
            if package:is_debug() then
                os.cp("lib/Linux_x86_64/dev/*", package:installdir("lib"))
            else
                os.cp("lib/Linux_x86_64/rel/*", package:installdir("lib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NGX_DLSS_GET_STATS_2", {includes = "nvsdk_ngx_helpers.h"}))
    end)
