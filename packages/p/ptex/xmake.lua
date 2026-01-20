package("ptex")
    set_homepage("http://ptex.us/")
    set_description("Per-Face Texture Mapping for Production Rendering")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/wdas/ptex/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wdas/ptex.git")

    add_versions("v2.5.1", "6b4b55f562a0f9492655fcb7686ecc335a2a4dacc1de9f9a057a32f3867a9d9e")
    add_versions("v2.3.2", "30aeb85b965ca542a8945b75285cd67d8e207d23dbb57fcfeaab587bb443402b")
    add_versions("v2.4.1", "664253b84121251fee2961977fe7cf336b71cd846dc235cd0f4e54a0c566084e")
    add_versions("v2.4.2", "c8235fb30c921cfb10848f4ea04d5b662ba46886c5e32ad5137c5086f3979ee1")
    add_versions("v2.4.3", "435aa2ee1781ff24859bd282b7616bfaeb86ca10604b13d085ada8aa7602ad27")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_check("android", function (package)
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(ptex): need ndk api level > 21 for android")
    end)

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end

        if package:version() and package:version():lt("2.5.0") then
            package:add("deps", "zlib")
        else
            package:add("deps", "libdeflate")
        end

        if not package:config("shared") then
            package:add("defines", "PTEX_STATIC")
        end
    end)

    on_install("!mingw or mingw|!i386", function (package)
        if package:version() and package:version():ge("2.5.0") and package:is_debug() then
            io.replace("src/ptex/PtexCache.h", "static const int maxMruFiles", "static constexpr int maxMruFiles", {plain = true})
        end
        io.replace("src/ptex/PtexPlatform.h", "sys/types.h", "unistd.h", {plain = true})
        io.replace("src/ptex/PtexPlatform.h", "#include <stdlib.h>", "#include <stdlib.h>\n#include <unistd.h>", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(src/tests)", "", {plain = true})

        local libdeflate = package:dep("libdeflate"):config("shared") and "libdeflate_shared" or "libdeflate_static"
        io.replace("src/ptex/CMakeLists.txt", "libdeflate_static", libdeflate, {plain = true})
        io.replace("src/ptex/CMakeLists.txt", "libdeflate_shared", libdeflate, {plain = true})

        local configs = {}
        if package:config("cmake") then
            table.insert(configs, "-DPTEX_BUILD_DOCS=OFF")
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DPTEX_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DPTEX_BUILD_STATIC_LIBS=" .. (not package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            configs.ver = package:version()
            configs.libdeflate = package:dep("libdeflate")
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Ptex::String error;
                PtexPtr<PtexCache> c(PtexCache::create(0,0));
            }
        ]]}, {includes = "Ptexture.h"}))
    end)
