package("suitesparse")
    set_homepage("https://people.engr.tamu.edu/davis/suitesparse.html")
    set_description("SuiteSparse is a suite of sparse matrix algorithms")

    add_urls("https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DrTimothyAldenDavis/SuiteSparse.git")

    add_versions("v7.12.2", "679412daa5f69af96d6976595c1ac64f252287a56e98cc4a8155d09cc7fd69e8")
    add_versions("v7.12.1", "794ae22f7e38e2ac9f5cbb673be9dd80cdaff2cdf858f5104e082694f743b0ba")
    add_versions("v7.11.0", "93ed4c4e546a49fc75884c3a8b807d5af4a91e39d191fbbc60a07380b12a35d1")
    add_versions("v7.8.1", "b645488ec0d9b02ebdbf27d9ae307f705de2b6133edb64617a72c7b4c6c3ff44")
    add_versions("v7.7.0", "529b067f5d80981f45ddf6766627b8fc5af619822f068f342aab776e683df4f3")
    add_versions("v7.6.0", "19cbeb9964ebe439413dd66d82ace1f904adc5f25d8a823c1b48c34bd0d29ea5")
    add_versions("v5.10.1", "acb4d1045f48a237e70294b950153e48dce5b5f9ca8190e86c2b8c54ce00a7ee")
    add_versions("v5.12.0", "5fb0064a3398111976f30c5908a8c0b40df44c6dd8f0cc4bfa7b9e45d8c647de")
    add_versions("v5.13.0", "59c6ca2959623f0c69226cf9afb9a018d12a37fab3a8869db5f6d7f83b6b147d")
    add_versions("v7.5.1", "dccfb5f75aa83fe2edb4eb2462fc984a086c82bad8433f63c31048d84b565d74")

    add_patches("5.x", path.join(os.scriptdir(), "patches", "5.10.1", "msvc.patch"), "8ac61e9acfaa864a2528a14d3a7e6e86f6e6877de2fe93fdc87876737af5bf31")

    add_configs("openmp", {description = "Enable OpenMP support.", default = true, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("blas", {description = "Set BLAS vendor.", default = "openblas", type = "string", values = {"mkl", "openblas", "apple"}})
    add_configs("blas_static", {description = "Use static BLAS library.", default = true, type = "boolean"})
    add_configs("graphblas", {description = "Enable GraphBLAS module.", default = not is_arch("x86"), type = "boolean"})
    add_configs("graphblas_static", {description = "Enable static GraphBLAS module.", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::suitesparse")
    elseif is_plat("linux") then
        add_extsources("pacman::suitesparse", "apt::libsuitesparse-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::suite-sparse")
    end

    if not is_plat("windows") then
        add_deps("gmp", "mpfr")
    end
    if is_plat("linux") then
        add_syslinks("m", "rt")
    end

    on_load("windows", "macosx", "linux", function (package)
        local version = package:version()
        if version then
            if version:ge("7.4.0") then
                package:add("deps", "cmake")
            end
            if version:lt("6.0.0") then
                package:add("deps", "metis")
            end
        end

        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:config("blas") == "apple" then
            package:add("frameworks", "Accelerate")
        else
            package:add("deps", package:config("blas"))
        end
        if version and version:ge("7.4.0") then
            local suffix = ""
            if package:is_plat("windows") and not package:config("shared") then
                suffix = "_static"
                if package:config("graphblas") then
                    package:add("links", "graphblas" .. (package:config("graphblas_static") and "_static" or ""))
                end
            end
            for _, lib in ipairs({"lagraphx", "lagraph", "graphblas", "spex", "spqr", "rbio", "ParU", "umfpack", "ldl", "klu", "klu_cholmod", "cxsparse", "cholmod", "colamd", "ccolamd", "camd", "btf", "amd", "suitesparse_mongoose", "suitesparseconfig"}) do
                package:add("links", lib .. suffix)
            end
        else
            if package:config("cuda") then
                package:add("deps", "cuda", {system = true, configs = {utils = {"cublas"}}})
                package:add("links", "GPUQREngine")
                package:add("links", "SuiteSparse_GPURuntime")
            end
            for _, lib in ipairs({"SPQR", "UMFPACK", "LDL", "KLU", "CXSparse", "CHOLMOD", "COLAMD", "CCOLAMD", "CAMD", "BTF", "AMD", "suitesparseconfig"}) do
                package:add("links", lib)
            end
        end
    end)

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        if package:version() and package:version():ge("7.4.0") then
            local configs = {"-DSUITESPARSE_DEMOS=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
            table.insert(configs, "-DGRAPHBLAS_BUILD_STATIC_LIBS=" .. (package:config("graphblas_static") and "ON" or "OFF"))
            table.insert(configs, "-DSUITESPARSE_USE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
            table.insert(configs, "-DSUITESPARSE_USE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
            local bla_vendor = {mkl = "Intel10_64lp", openblas = "OpenBLAS", apple = "Apple"}
            table.insert(configs, "-DBLA_VENDOR=" .. bla_vendor[package:config("blas")])
            table.insert(configs, "-DBLA_STATIC=" .. (package:config("blas_static") and "ON" or "OFF"))
            if package:is_plat("windows") then
                if not package:has_tool("cxx", "ifort", "ifx") then
                    table.insert(configs, "-DSUITESPARSE_USE_FORTRAN=OFF")
                end
                if package:config("graphblas") then
                    table.insert(configs, "-DSUITESPARSE_ENABLE_PROJECTS=suitesparse_config;mongoose;amd;btf;camd;ccolamd;colamd;cholmod;cxsparse;ldl;klu;umfpack;paru;rbio;spqr;graphblas;lagraph") -- remove spex since it does not support windows
                else
                    table.insert(configs, "-DSUITESPARSE_ENABLE_PROJECTS=suitesparse_config;mongoose;amd;btf;camd;ccolamd;colamd;cholmod;cxsparse;ldl;klu;umfpack;paru;rbio;spqr")
                end
                local vs_sdkver = import("core.tool.toolchain").load("msvc"):config("vs_sdkver")
                if vs_sdkver then
                    local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
                    assert(tonumber(build_ver) >= 18362, "cpuinfo requires Windows SDK to be at least 10.0.18362.0")
                    table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
                    table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
                end
            elseif not package:config("graphblas") then
                table.insert(configs, "-DSUITESPARSE_ENABLE_PROJECTS=suitesparse_config;mongoose;amd;btf;camd;ccolamd;colamd;cholmod;cxsparse;ldl;klu;umfpack;paru;rbio;spqr;spex")
            end
            import("package.tools.cmake").install(package, configs)
        else
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            local configs = {}
            configs.with_blas = package:config("blas")
            configs.with_cuda = package:config("cuda")
            configs.graphblas = package:config("graphblas")
            configs.graphblas_static = package:config("graphblas_static")
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        if package:version() and package:version():ge("7.4.0") then
            assert(package:has_cfuncs("SuiteSparse_start", {includes = "suitesparse/SuiteSparse_config.h"}))
        else
            assert(package:has_cfuncs("SuiteSparse_start", {includes = "SuiteSparse_config.h"}))
        end
    end)
