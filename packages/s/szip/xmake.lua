package("szip")

    set_homepage("https://support.hdfgroup.org/doc_resource/SZIP/")
    set_description("Szip is an implementation of the extended-Rice lossless compression algorithm.")

    add_urls("https://support.hdfgroup.org/ftp/lib-external/szip/$(version)/src/szip-$(version).tar.gz")
    add_versions("2.1.1", "21ee958b4f2d4be2c9cabfa5e1a94877043609ce86fde5f286f105f7ff84d412")

    on_load("windows|x64", function (package)
        if package:config("shared") then
            package:add("defines", "SZ_BUILT_AS_DYNAMIC_LIB")
        end
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake")
        end
    end)

    on_install("windows|x64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.tryrm(package:installdir("bin", "*.dll|szip.dll"))
        if package:config("shared") then
            os.tryrm(package:installdir("lib", "libszip.lib"))
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("SZ_Compress", {includes = {"stddef.h", "szlib.h"}}))
    end)
