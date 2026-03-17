package("dlss")
    set_homepage("https://github.com/NVIDIA/DLSS")
    set_description("NVIDIA DLSS is a new and improved deep learning neural network that boosts frame rates and generates beautiful, sharp images for your games")
    set_license("NVIDIA RTX SDKs")

    add_urls("https://github.com/NVIDIA/DLSS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/DLSS.git", {submodules = false})

    add_versions("v310.5.3", "6b54a684b5b31e819a51742ad534abb4e8cdada76572f061a5d3149c7432a0a1")
    add_versions("v310.5.0", "9effc97025eb8c61f85e41b97e4ccaaed18313e245c7f0b739525c6f26a5d4e6")
    add_versions("v310.4.0", "a11a36977746cb0bb9ffc20171738db9bbb9cc81e3c2693d0aa65e5f412d6080")
    add_versions("v310.3.0", "c9033a5c5acd428e863aeca7288d5947f233c666c6cc97627bd6a74c4a42e84f")
    add_versions("v310.2.1", "1aa9e6bbb68507a7eed2ec3eaed842ced08d3036018c3d9ee2297fbd6aa460e6")
    add_versions("v310.1.0", "f042769df59a3f4a5f80421e60d848d26d4f8a7c4848da410507fc07e50522f4")
    add_versions("v3.7.20", "904d771551526dd6aa458f0db7b85fe4abb8f49ce0307d377e8da089628bf9ec")

    set_policy("package.precompiled", false)

    on_install("windows|x64", "linux|x86_64", function (package)
        os.cp("include", package:installdir())
        if is_plat("windows") then
            if package:version() and package:version():ge("310.1.0") then
                os.cp("lib/Windows_x86_64/x64/*.lib", package:installdir("lib"))
            else
                os.cp("lib/Windows_x86_64/x86_64/*.lib", package:installdir("lib"))
            end
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
