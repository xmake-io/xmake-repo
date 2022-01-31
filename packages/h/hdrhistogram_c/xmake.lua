package("hdrhistogram_c")
    set_homepage("https://github.com/HdrHistogram/HdrHistogram_c")
    set_description("C port of High Dynamic Range (HDR) Histogram")

    add_urls("https://github.com/HdrHistogram/HdrHistogram_c.git")
    add_versions("2021.1.25", "7615a45ed0975d76dced55eaeac4ad13b150a983")

    add_deps("cmake", "zlib")

    on_install("linux", "windows", "macosx", function (package)
        local configs = {"-DHDR_HISTOGRAM_BUILD_PROGRAMS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DHDR_HISTOGRAM_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DHDR_HISTOGRAM_INSTALL_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DHDR_HISTOGRAM_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHDR_HISTOGRAM_INSTALL_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hdr_init", {includes = "hdr/hdr_histogram.h"}))
    end)
