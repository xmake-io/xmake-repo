package("niftiheader")
    set_kind("library", {headeronly = true})
    set_homepage("https://nifti.nimh.nih.gov/")
    add_urls("https://github.com/xmake-mirror/nifti2.git")
    add_versions("0.0.1", "d2461b27888fd5db659edb8b788c7ce6203f703c")

    on_install(function(package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_ctypes("nifti_1_header", {includes = {"nifti1.h"}}))
        assert(package:has_ctypes("nifti_2_header", {includes = {"nifti2.h"}}))
    end)
