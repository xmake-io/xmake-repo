package("libzippp")
    set_homepage("https://github.com/ctabin/libzippp")
    set_description("C++ wrapper for libzip")

    local libzip_version_map = {
        ["7.1"] = "1.10.1"
    }

    add_urls("https://github.com/ctabin/libzippp.git")
    add_urls("https://github.com/ctabin/libzippp/archive/refs/tags/$(version).tar.gz", {
        version = function (version)
            local v_str = tostring(version)
            return format("libzippp-v%s-%s", v_str, libzip_version_map[v_str])
        end
    })

    add_versions("7.1", "9ded3c4b5641e65d2b3a3dd0cbc4106209ee17c17df70e5187e7171420752546")

    add_configs("encryption", {description = "Build with encryption enabled", default = false, type = "boolean"})

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            if package:is_arch("armeabi-v7a") then
                local ndkver = package:toolchain("ndk"):config("ndkver")
                assert(ndkver and tonumber(ndkver) > 22, "package(libzip) require ndk version > 22")
            end
        end)
    end

    on_load(function (package)
        package:add("deps", "libzip v" .. libzip_version_map[package:version_str()])
        if package:config("encryption") then
            package:add("defines", "LIBZIPPP_WITH_ENCRYPTION")
        end
    end)

    on_install("!cross", function (package)
        local configs = {
            "-DLIBZIPPP_BUILD_TESTS=OFF",
            "-DLIBZIPPP_CMAKE_CONFIG_MODE=ON",
            "-DLIBZIPPP_GNUINSTALLDIRS=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBZIPPP_ENABLE_ENCRYPTION=" .. (package:config("encryption") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "libzippp.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace libzippp;
            void test() {
                ZipArchive zf("archive.zip");
                zf.open(ZipArchive::ReadOnly);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "libzippp/libzippp.h"}))
    end)
