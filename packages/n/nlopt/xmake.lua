package("nlopt")

    set_homepage("https://github.com/stevengj/nlopt/")
    set_description("NLopt is a library for nonlinear local and global optimization, for functions with and without gradient information.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/stevengj/nlopt/archive/$(version).tar.gz",
             "https://github.com/stevengj/nlopt.git")
    add_versions("v2.7.0", "b881cc2a5face5139f1c5a30caf26b7d3cb43d69d5e423c9d78392f99844499f")
    add_versions("v2.7.1", "db88232fa5cef0ff6e39943fc63ab6074208831dc0031cf1545f6ecd31ae2a1a")

    add_deps("cmake")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "NLOPT_DLL")
        end
    end)

    on_install("linux", "windows", "macosx", function (package)
        local configs = {"-DNLOPT_PYTHON=OFF", "-DNLOPT_OCTAVE=OFF", "-DNLOPT_MATLAB=OFF", "-DNLOPT_GUILE=OFF", "-DNLOPT_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nlopt_create", {includes = "nlopt.h"}))
    end)
