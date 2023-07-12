package("cimg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/greyclab/cimg")
    set_description("Small and open-source C++ toolkit for image processing")
    set_license("CeCILL-C")

    add_urls("https://github.com/greyclab/cimg/archive/refs/tags/$(version).tar.gz", {version = function(version)
        return version:gsub("%v", "v.")
    end})
    add_urls("https://github.com/greyclab/cimg.git")
    add_versions("v3.2.6", "1fcca9a7a453aa278660c10d54c6db9b4c614b6a29250adeb231e95a0be209e7")

    on_install(function (package)
        os.cp("CImg.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("cimg_library::CImg<>", {
            includes = "CImg.h", configs = {defines = "cimg_display=0"}
        }))
    end)
