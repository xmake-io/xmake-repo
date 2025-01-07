package("miniz")

    set_homepage("https://github.com/richgel999/miniz/")
    set_description("miniz: Single C source file zlib-replacement library")
    set_license("MIT")

    add_urls("https://github.com/richgel999/miniz/archive/refs/tags/$(version).tar.gz",
             "https://github.com/richgel999/miniz.git")

    add_versions("3.0.2", "c4b4c25a4eb81883448ff8924e6dba95c800094a198dc9ce66a292ac2ef8e018")
    add_versions("2.2.0", "bd1136d0a1554520dcb527a239655777148d90fd2d51cf02c36540afc552e6ec")
    add_versions("2.1.0", "95f9b23c92219ad2670389a23a4ed5723b7329c82c3d933b7047673ecdfc1fea")

    add_includedirs("include", "include/miniz")

    add_deps("cmake")

    on_install(function (package)
        if version:lt("3.0.0") then
            add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
        end
        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW", "-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTS=OFF", "-DINSTALL_PROJECT=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mz_compress", {includes = "miniz.h"}))
    end)
