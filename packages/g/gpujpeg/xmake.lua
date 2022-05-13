package("gpujpeg")
    set_homepage("https://github.com/CESNET/GPUJPEG")
    set_description("JPEG encoder and decoder library and console application for NVIDIA GPUs from CESNET and SITOLA of Faculty of Informatics at Masaryk University.")

    add_urls("https://github.com/CESNET/GPUJPEG/archive/refs/tags/$(version).tar.gz",
             "https://github.com/CESNET/GPUJPEG.git")
    add_versions("continuous", "02be161bb8eca4479f186c700d96275784da200341b7dc67d60714e484af9cee")

    add_deps("cmake")
    add_deps("cuda", {system = true})

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                struct gpujpeg_parameters param;
                gpujpeg_set_default_parameters(&param);
            }
        ]]}, {includes = {"libgpujpeg/gpujpeg.h"}}))
    end)
