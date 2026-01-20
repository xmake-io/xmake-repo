package("miniz")
    set_homepage("https://github.com/richgel999/miniz/")
    set_description("miniz: Single C source file zlib-replacement library")
    set_license("MIT")

    add_urls("https://github.com/richgel999/miniz/archive/refs/tags/$(version).tar.gz",
             "https://github.com/richgel999/miniz.git")

    add_versions("3.1.0", "09569fc19d060ac9f5999ba9356728c2494ebe6a24ac0eb0a6b6ae3d396cfea6")
    add_versions("3.0.2", "c4b4c25a4eb81883448ff8924e6dba95c800094a198dc9ce66a292ac2ef8e018")
    add_versions("2.2.0", "bd1136d0a1554520dcb527a239655777148d90fd2d51cf02c36540afc552e6ec")
    add_versions("2.1.0", "95f9b23c92219ad2670389a23a4ed5723b7329c82c3d933b7047673ecdfc1fea")

    add_configs("cmake", {description = "Use cmake buildsystem", default = true, type = "boolean"})

    add_includedirs("include", "include/miniz")

    on_load(function (package)
        local version = package:version()
        if version and version:lt("2.2.0") then
            package:config_set("cmake", false)
        end

        if package:config("cmake") then
            package:add("deps", "cmake")
            if not package:config("shared") then
                package:add("defines", "MINIZ_STATIC_DEFINE")
            end
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW", "-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTS=OFF", "-DINSTALL_PROJECT=ON"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, {ver = package:version()})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mz_compress", {includes = "miniz.h"}))
    end)
