package("ls-hpack")
    set_homepage("https://github.com/litespeedtech/ls-hpack")
    set_description("LiteSpeed HPACK (RFC7541) Library")
    set_license("MIT")

    add_urls("https://github.com/litespeedtech/ls-hpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/litespeedtech/ls-hpack.git")

    add_versions("v2.3.3", "3d7d539bd659fefc7168fb514368065cb12a1a7a0946ded60e4e10f1637f1ea2")

    add_deps("cmake")
    add_deps("xxhash")

    on_install(function (package)
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY(bin)", "", {plain = true})
        io.replace("CMakeLists.txt", "SHARED EQUAL 1", "BUILD_SHARED_LIBS", {plain = true})

        local configs = {"-DENABLE_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if  package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").build(package, configs, {packagedeps = "xxhash"})

        os.vcp("*.h", package:installdir("include"))
        os.vcp("compat/**.h", package:installdir("include/sys"))
        os.vcp("**.a", package:installdir("lib"))
        os.vcp("**.dylib", package:installdir("lib"))
        os.vcp("**.lib", package:installdir("lib"))
        os.vcp("**.so", package:installdir("lib"))
        os.vcp("**.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lshpack_enc_init", {includes = "lshpack.h"}))
    end)
