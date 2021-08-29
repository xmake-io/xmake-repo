package("libmng")

    set_homepage("https://libmng.com/")
    set_description("libmng - The reference library for reading, displaying, writing and examining Multiple-Image Network Graphics.")

    add_urls("https://sourceforge.net/projects/libmng/files/libmng-devel/$(version)/libmng-$(version).tar.gz")
    add_versions("2.0.3", "cf112a1fb02f5b1c0fce5cab11ea8243852c139e669c44014125874b14b7dfaa")

    add_deps("cmake")
    add_deps("zlib", "libjpeg-turbo", "lcms 2.x")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "MNG_USE_DLL")
        end
        package:add("defines", "WIN32")
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.rm("config.h")
        local configs = {"-DMNG_INSTALL_LIB_DIR=lib"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mng_initialize", {includes = "libmng.h"}))
    end)
