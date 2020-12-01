package("openjpeg")

    set_homepage("http://www.openjpeg.org/")
    set_description("OpenJPEG is an open-source JPEG 2000 codec written in C language.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/uclouvain/openjpeg/archive/v$(version).tar.gz",
             "https://github.com/uclouvain/openjpeg.git")
    add_versions("2.3.1", "63f5a4713ecafc86de51bfad89cc07bb788e9bba24ebbf0c4ca637621aadb6a9")

    add_deps("cmake")
    add_deps("lcms", "libtiff", "libpng")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_DOC=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        os.mv(package:installdir("include", "openjpeg*", "*.h"), package:installdir("include"))
        package:add("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opj_version", {includes = "openjpeg.h"}))
    end)
