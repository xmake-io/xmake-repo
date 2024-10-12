package("libebur128")
    set_homepage("https://github.com/jiixyj/libebur128")
    set_description("A library implementing the EBU R128 loudness standard.")
    set_license("MIT")

    add_urls("https://github.com/jiixyj/libebur128/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jiixyj/libebur128.git")

    add_versions("v1.2.6", "baa7fc293a3d4651e244d8022ad03ab797ca3c2ad8442c43199afe8059faa613")

    add_deps("cmake")

    on_install("!windows or windows|!arm64", function (package)
        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "ebur128.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ebur128_init", {includes = "ebur128.h"}))
    end)
