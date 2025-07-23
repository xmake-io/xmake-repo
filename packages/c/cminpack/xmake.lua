package("cminpack")
    set_homepage("https://devernay.github.io/cminpack/")
    set_description("A C/C++ rewrite of the MINPACK software (originally in FORTRAN) for solving nonlinear equations and nonlinear least squares problems")

    add_urls("https://github.com/devernay/cminpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/devernay/cminpack.git")
    add_versions("v1.3.11", "45675fac0a721a1c7600a91a9842fe1ab313069db163538f2923eaeddb0f46de")
    add_versions("v1.3.9", "aa37bac5b5caaa4f5805ea5c4240e3834c993672f6dab0b17190ee645e251c9f")

    local support_openblas = is_plat("linux", "macosx") or (is_plat("windows") and is_arch("x86", "x64"))
    add_configs("blas", {description = "BLAS library to compile with.", default = (support_openblas and "openblas" or nil), type = "string", values = {"openblas", "mkl", "apple"}})
    add_configs("long_double", {description = "Enable extended precision.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_includedirs("include/cminpack-1")

    add_deps("cmake")

    on_load(function (package)
        if package:config("blas") and not package:config("long_double") then
            package:add("deps", package:config("blas"))
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "msys", "android", "iphoneos", "wasm", function (package)
        if package:is_plat("windows", "mingw") and (not package:config("shared")) then
            package:add("defines", "CMINPACK_NO_DLL")
        end
        if not package:config("long_double") then
            io.replace("CMakeLists.txt", "${SIZEOF_LONG_DOUBLE} GREATER ${SIZEOF_DOUBLE}", "FALSE", {plain = true})
        end
        local has_blas = package:config("blas") and not package:config("long_double")

        local configs = {"-DBUILD_EXAMPLES=OFF", "-DENABLE_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_BLAS=" .. (has_blas and "ON" or "OFF"))
        if has_blas then
            local bla_vendor = {mkl = "Intel10_64lp", openblas = "OpenBLAS", apple = "Apple"}
            table.insert(configs, "-DBLA_VENDOR=" .. bla_vendor[package:config("blas")])
            if package:dep(package:config("blas")) then
                local bla_static = not package:dep(package:config("blas")):config("shared")
                table.insert(configs, "-DBLA_STATIC=" .. (bla_static and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lmdif", {includes = "minpack.h"}))
    end)
