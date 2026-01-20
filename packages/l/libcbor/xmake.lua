package("libcbor")
    set_homepage("https://github.com/PJK/libcbor")
    set_description("CBOR protocol implementation for C")
    set_license("MIT")

    add_urls("https://github.com/pjk/libcbor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pjk/libcbor.git", {submodules = false})

    add_versions("v0.13.0", "95a7f0dd333fd1dce3e4f92691ca8be38227b27887599b21cd3c4f6d6a7abb10")
    add_versions("v0.12.0", "5368add109db559f546d7ed10f440f39a273b073daa8da4abffc83815069fa7f")
    add_versions("v0.11.0", "89e0a83d16993ce50651a7501355453f5250e8729dfc8d4a251a78ea23bb26d7")

    add_deps("cmake")

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "CBOR_STATIC_DEFINE")
        end

        local configs = {
            "-DWITH_EXAMPLES=OFF",
            "-DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSANITIZE=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=" .. (package:config("lto") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cbor_new_definite_map", {includes = "cbor.h"}))
    end)
