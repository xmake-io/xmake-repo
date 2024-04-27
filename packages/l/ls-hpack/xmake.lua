package("ls-hpack")
    set_homepage("https://github.com/litespeedtech/ls-hpack")
    set_description("LiteSpeed HPACK (RFC7541) Library")
    set_license("MIT")

    add_urls("https://github.com/litespeedtech/ls-hpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/litespeedtech/ls-hpack.git")

    add_versions("v2.3.3", "3d7d539bd659fefc7168fb514368065cb12a1a7a0946ded60e4e10f1637f1ea2")

    add_patches("v2.3.3", "patches/v2.3.3/fix-cmake-install.patch", "272e43d3f19843f03b11b0c040ddecb5dedf5667ac7ff8102ed29cc5528a5693")

    add_deps("cmake")
    add_deps("xxhash")

    on_install(function (package)
        local configs = {
            "-DXXH_INCLUDE_DIR=" .. package:dep("xxhash"):installdir("include")
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSHARED=" .. (package:config("shared") and "1" or "0"))
        if  package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "xxhash"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lshpack_enc_init", {includes = "lshpack.h"}))
    end)
