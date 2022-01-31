package("hdrhistogram_c")
    set_homepage("https://github.com/HdrHistogram/HdrHistogram_c")
    set_description("C port of High Dynamic Range (HDR) Histogram")

    add_urls("https://github.com/HdrHistogram/HdrHistogram_c.git")
    add_versions("2021.1.25", "7615a45ed0975d76dced55eaeac4ad13b150a983")

    add_deps("cmake")

    on_install("linux", "windows", "macosx", function (package)
        local configs = {"-DHDR_HISTOGRAM_BUILD_PROGRAMS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("hdr_log_reader_init", {includes = "hdr_histogram.h"}))
    end)
