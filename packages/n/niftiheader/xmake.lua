package("niftiheader")
    set_kind("library", {headeronly = true})
    add_urls("https://nifti.nimh.nih.gov/pub/dist/src/nifti2/")
    add_versions("latest", "")

    on_download(function(package, opt)
        import("net.http")
        http.download(opt.url .. "nifti1.h", path.join(opt.sourcedir, "nifti1.h"))
        http.download(opt.url .. "nifti2.h", path.join(opt.sourcedir, "nifti2.h"))
    end)

    on_install(function(package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_ctypes("nifti_1_header", {includes = {"nifti1.h"}}))
        assert(package:has_ctypes("nifti_2_header", {includes = {"nifti2.h"}}))
    end)
