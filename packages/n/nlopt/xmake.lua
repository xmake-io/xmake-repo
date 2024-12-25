package("nlopt")
    set_homepage("https://github.com/stevengj/nlopt")
    set_description("library for nonlinear optimization, wrapping many algorithms for global and local, constrained or unconstrained, optimization")
    set_license("LGPL-2.1")

    add_urls("https://github.com/stevengj/nlopt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stevengj/nlopt.git")

    add_versions("v2.9.1", "1e6c33f8cbdc4138d525f3326c231f14ed50d99345561e85285638c49b64ee93")
    add_versions("v2.8.0", "e02a4956a69d323775d79fdaec7ba7a23ed912c7d45e439bc933d991ea3193fd")
    add_versions("v2.7.0", "b881cc2a5face5139f1c5a30caf26b7d3cb43d69d5e423c9d78392f99844499f")
    add_versions("v2.7.1", "db88232fa5cef0ff6e39943fc63ab6074208831dc0031cf1545f6ecd31ae2a1a")

    add_configs("octave", {description = "build octave bindings", default = false, type = "boolean", readonly = true})
    add_configs("matlab", {description = "build matlab bindings", default = false, type = "boolean", readonly = true})
    add_configs("guile", {description = "build guile bindings", default = false, type = "boolean", readonly = true})

    add_deps("cmake")

    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "NLOPT_DLL")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DNLOPT_TESTS=OFF",
            "-DNLOPT_PYTHON=OFF",
            "-DNLOPT_SWIG=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNLOPT_OCTAVE=" .. (package:config("octave") and "ON" or "OFF"))
        table.insert(configs, "-DNLOPT_MATLAB=" .. (package:config("matlab") and "ON" or "OFF"))
        table.insert(configs, "-DNLOPT_GUILE=" .. (package:config("guile") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nlopt_create", {includes = "nlopt.h"}))
    end)
