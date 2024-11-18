package("lighthook")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/SamuelTulach/LightHook")
    set_description("Single-header, minimalistic, cross-platform hook library written in pure C ")
    set_license("MIT")

    add_urls("https://github.com/SamuelTulach/LightHook/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SamuelTulach/LightHook.git")

    add_versions("2", "fae5bf8a3ea3d06377c10bcad9b4b8f3c1158598c8d64aa12409abdb701b095b")
	
    on_install("windows", function (package)
        os.cp("Source/LightHook.h", package:installdir("include","lighthook"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("CreateHook", {includes = {"lighthook/LightHook.h"}}))
    end)
