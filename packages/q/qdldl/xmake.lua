package("qdldl")
    set_homepage("https://github.com/osqp/qdldl")
    set_description("A free LDL factorisation routine")
    set_license("Apache-2.0")

    add_urls("https://github.com/osqp/qdldl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/osqp/qdldl.git")

    add_versions("v0.1.9", "7d1285b2db15cf2730dc83b3d16ed28412f558591108cca4f28d4438bf72ceed")
    add_versions("v0.1.8", "ecf113fd6ad8714f16289eb4d5f4d8b27842b6775b978c39def5913f983f6daa")
    add_versions("v0.1.7", "631ae65f367859fa1efade1656e4ba22b7da789c06e010cceb8b29656bf65757")

    add_includedirs("include", "include/qdldl")

    add_deps("cmake")

    on_install(function (package)
        if package:config("shared") then
            package:add("defines", "QDLDL_SHARED_LIB")
        end

        local configs = {"-DQDLDL_BUILD_DEMO_EXE=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DQDLDL_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DQDLDL_BUILD_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("QDLDL_etree", {includes = "qdldl/qdldl.h"}))
    end)
