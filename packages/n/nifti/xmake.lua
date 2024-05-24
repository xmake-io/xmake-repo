package("nifti")
    set_homepage("https://github.com/NIFTI-Imaging/nifti_clib")
    set_description("C libraries for NIFTI support")

    add_urls("https://github.com/NIFTI-Imaging/nifti_clib.git")
    add_versions("2024.01.25", "f24bec503f1a5d501c0413c1bb8aa3d6e04aebda")

    add_configs("nifti2", {description = "Build nifti2.", default = false, type = "boolean"})
    add_configs("cifti",  {description = "Build cifti.",  default = false, type = "boolean"})
    add_configs("fslio",  {description = "Build fslio.",  default = false, type = "boolean"})
    add_configs("tools",  {description = "Build tools.",  default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("zlib")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DNIFTI_INSTALL_NO_DOCS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_NIFTI2_CODE=" .. (package:config("nifti2") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_CIFTI_CODE=" .. (package:config("cifti") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_FSL_CODE=" .. (package:config("fslio") and "ON" or "OFF"))
        table.insert(configs, "-DNIFTI_BUILD_APPLICATIONS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nifticdf", {includes = "nifticdf.h"}))
    end)
