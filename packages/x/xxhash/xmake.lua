package("xxhash")
    set_homepage("http://cyan4973.github.io/xxHash/")
    set_description("xxHash is an extremely fast non-cryptographic hash algorithm, working at RAM speed limit.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Cyan4973/xxHash/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Cyan4973/xxHash.git")

    add_versions("v0.8.3", "aae608dfe8213dfd05d909a57718ef82f30722c392344583d3f39050c7f29a80")
    add_versions("v0.8.2", "baee0c6afd4f03165de7a4e67988d16f0f2b257b51d0e3cb91909302a26a79c4")
    add_versions("v0.8.1", "3bb6b7d6f30c591dd65aaaff1c8b7a5b94d81687998ca9400082c739a690436c")
    add_versions("v0.8.0", "7054c3ebd169c97b64a92d7b994ab63c70dd53a06974f1f630ab782c28db0f4f")

    add_configs("cmake", {description = "Use cmake buildsystem", default = true, type = "boolean"})
    add_configs("dispatch", {description = "Enable dispatch mode", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "XXH_IMPORT", "WIN32")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {"-DXXHASH_BUILD_XXHSUM=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:config("dispatch") then
                -- if((DEFINED DISPATCH) AND (DEFINED PLATFORM))
                table.insert(configs, "-DDISPATCH=ON")
            end

            os.cd("cmake_unofficial")
            import("package.tools.cmake").install(package, configs)
        else
            io.writefile("xmake.lua", [[
                option("dispatch", {default = false})
                add_rules("mode.debug", "mode.release")
                add_rules("utils.install.pkgconfig_importfiles", {filename = "libxxhash.pc"})
                target("xxhash")
                    set_kind("$(kind)")
                    add_files("xxhash.c")
                    add_headerfiles("xxhash.h", "xxh3.h")
                    if is_plat("windows") and is_kind("shared") then
                        add_defines("XXH_EXPORT", "WIN32")
                    end
                    if has_config("dispatch") then
                        add_files("xxh_x86dispatch.c")
                        add_headerfiles("xxh_x86dispatch.h")
                    end
            ]])
            import("package.tools.xmake").install(package, {dispatch = package:config("dispatch")})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XXH_versionNumber", {includes = "xxhash.h"}))
    end)
