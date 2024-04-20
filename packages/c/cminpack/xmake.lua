package("cminpack")
    set_homepage("http://devernay.free.fr/hacks/cminpack/")
    set_description("A C/C++ rewrite of the MINPACK software (originally in FORTRAN) for solving nonlinear equations and nonlinear least squares problems")

    add_urls("https://github.com/devernay/cminpack.git")
    add_versions("2024.01.04", "cba7bcce88d93011411799ee3275caef18aaf7dd")

    add_configs("blas", {description = "Compile cminpack using cblas library if possible", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_includedirs("include/cminpack-1")

    add_deps("cmake")

    on_load(function (package)
        if package:config("blas") then
            package:add("deps", "openblas")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "msys", "android", "iphoneos", "wasm", function (package)
        if package:is_plat("windows", "mingw") and (not package:config("shared")) then
            package:add("defines", "CMINPACK_NO_DLL")
        end

        local configs = {"-DBUILD_EXAMPLES=OFF", "-DENABLE_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_BLAS=" .. (package:config("blas") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lmdif", {includes = "minpack.h"}))
    end)
