package("lsquic")
    set_homepage("https://github.com/litespeedtech/lsquic")
    set_description("LiteSpeed QUIC and HTTP/3 Library")
    set_license("MIT")

    add_urls("https://github.com/litespeedtech/lsquic/archive/refs/tags/$(version).tar.gz",
             "https://github.com/litespeedtech/lsquic.git")

    add_versions("v4.0.12", "9dfbb5617059f6085c3d796dae3850c9e8a65f2e35582af12babeed633a22be7")
    add_versions("v4.0.11", "b1c46951c1fc524a96923f4e380cb9fc6cc20bb8a8a41779351bcad6dcbe6e16")
    add_versions("v4.0.9", "bebb6e687138368d89ff3f67768692ac55b06925d63b011d000ce134b6ec98f1")
    add_versions("v4.0.8", "f18ff2fa0addc1c51833304b3d3ff0979ecf5f53f54f96bcd3442a40cfcd440b")

    add_patches(">=4.0.8", "patches/4.0.8/cmake.patch", "c9b8412fbd7df511dee4d57ea5dfa50bc527e015fc808270235b91abfd9baa89")

    add_configs("fiu", {description = "Use Fault Injection in Userspace (FIU)", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("zlib", "boringssl", "ls-qpack", "ls-hpack")

    add_includedirs("include/lsquic")

    on_load("windows", function (package)
        if not package:is_precompiled() then
            package:add("deps", "strawberry-perl")
        end
    end)

    on_install("windows|!arm64", "linux", "macosx", function (package)
        local opt = {}
        opt.packagedeps = {"ls-qpack", "ls-hpack"}
        if package:is_plat("windows") then
            opt.cxflags = "-DWIN32"
            -- https://github.com/litespeedtech/lsquic/issues/433
            package:add("defines", "WIN32", "WIN32_LEAN_AND_MEAN")
        end
        io.replace("CMakeLists.txt", "-WX", "", {plain = true})

        local boringssl = package:dep("boringssl")
        io.replace("CMakeLists.txt",
            "lib${LIB_NAME}${LIB_SUFFIX}",
            "lib${LIB_NAME}" .. (boringssl:config("shared") and ".so" or ".a"), {plain = true})

        local configs = {
            "-DLSQUIC_BIN=OFF",
            "-DLSQUIC_TESTS=OFF",
            "-DBORINGSSL_DIR=" .. boringssl:installdir(),
            "-DBORINGSSL_LIB=" .. boringssl:installdir("lib"),
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLSQUIC_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLSQUIC_FIU=" .. (package:config("fiu") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lsquic_global_init", {includes = "lsquic.h"}))
    end)
