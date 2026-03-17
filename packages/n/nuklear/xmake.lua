package("nuklear")

    set_kind("library", {headeronly = true})
    set_homepage("https://immediate-mode-ui.github.io/Nuklear/doc/index.html")
    set_description("A single-header ANSI C immediate mode cross-platform GUI library")
    set_license("MIT")

    add_urls("https://github.com/Immediate-Mode-UI/Nuklear/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Immediate-Mode-UI/Nuklear.git")

    add_versions("4.12.8", "2b5d278547cf7f4232d2a48334b8756c3c4533608bf01b2ebc9a4de0063eef08")
    add_versions("4.12.7", "5809afbb2e1182894d283f56e586d5aec09ab5ae9c936be51d55033ec6ea77bf")
    add_versions("4.12.6", "60a62c3a15b0d11a4cc74e0007ea42787e08548db4caa642ca9fd2208f47d8ca")
    add_versions("4.12.5", "1067ae54a2bde8b94b8db262618b75f63c8a6f4df2085ec0970bd9b210fbec0b")
    add_versions("4.12.4", "d698f78a44722fbc8617e6c749197d2b9d5f44b1a5adf3467ccbd8f9aa001411")
    add_versions("4.12.3", "93d32d02ac5c5b17ecc243bb6436da3dc79e656eaa9046e053b8a922e1ee1ad3")
    add_versions("4.12.2", "a705e626a7190722fc5bd3b298e0be35b3d3d92eccf017660ef251cab29fcc94")
    add_versions("4.12.0", "4cb80084d20d20561548a2941b6d1eb7c30e6f0b9405e0d5df84bae3c1d7bbaf")
    add_versions("4.10.5", "6c80cbd0612447421fa02ad92f4207da2cd019a14d94885dfccac1aadc57926a")

    on_load("mingw", function (package)
        -- see https://github.com/Immediate-Mode-UI/Nuklear/issues/320
        package:add("defines", "NK_INCLUDE_FIXED_TYPES")
    end)

    on_install(function (package)
        os.cp("nuklear.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("nuklear.h"))
    end)
