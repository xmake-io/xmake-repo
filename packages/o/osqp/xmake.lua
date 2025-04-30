package("osqp")
    set_homepage("https://osqp.org/")
    set_description("The Operator Splitting QP Solver")
    set_license("Apache-2.0")

    add_urls("https://github.com/osqp/osqp/releases/download/$(version)/osqp-$(version)-src.tar.gz",
             "https://github.com/osqp/osqp.git")

    add_versions("v1.0.0", "ec0bb8fd34625d0ea44274ab3e991aa56e3e360ba30935ae62476557b101c646")
    add_versions("v0.6.3", "285b2a60f68d113a1090767ec8a9c81a65b3af2d258f8c78a31cc3f98ba58456")

    add_patches("0.6.3", "patches/0.6.3/cmake.patch", "ffe3809019eebae7559e8c4016431e9d3e9bc35776d9affe65b83904dd753999")

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    elseif is_host("linux", "macosx", "bsd") then
        add_deps("pkg-config")
    end
    add_deps("qdldl")

    on_install(function (package)
        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("osqp_solve", {includes = "osqp/osqp.h"}))
    end)
