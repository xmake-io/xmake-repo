package("fftw")
    set_homepage("http://fftw.org/")
    set_description("A C subroutine library for computing the discrete Fourier transform (DFT) in one or more dimensions.")
    set_license("GPL-2.0")

    add_urls("http://fftw.org/fftw-$(version).tar.gz")

    add_versions("3.3.8", "6113262f6e92c5bd474f2875fa1b01054c4ad5040f6b0da7c03c98821d9ae303")
    add_versions("3.3.9", "bf2c7ce40b04ae811af714deb512510cc2c17b9ab9d6ddcf49fe4487eea7af3d")
    add_versions("3.3.10", "56c932549852cddcfafdab3820b0200c7742675be92179e59e6215b340e26467")

    add_configs("precision", {description = "Float number precision.", default = "double", type = "string", values = {"float", "double", "quad", "long"}})
    add_configs("thread", {description = "Thread model used.", default = "fftw", type = "string", values = {"none", "fftw", "openmp"}})
    add_configs("enable_mpi", {description = "Enable MPI support.", default = false, type = "boolean"})
    add_configs("simd", {description = "SIMD instruction sets used.", default = "avx2", type = "string", values = {"none", "sse", "sse2", "avx", "avx2", "avx512", "avx-128-fma", "kcvi", "altivec", "vsx", "neon", "generic-simd128", "generic-simd256"}})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    if not is_plat("linux") then
        add_deps("cmake")
    end

    on_load(function (package)
        if package:config("thread") == "openmp" then
            package:add("deps", "openmp")
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "FFTW_DLL")
        end

        if package:is_arch("arm.*") then
            package:config_set("simd", "none")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_COMBINED_THREADS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("precision") == "float" then
            table.insert(configs, "-DENABLE_FLOAT=ON")
        elseif package:config("precision") == "quad" then
            table.insert(configs, "-DENABLE_QUAD_PRECISION=ON")
        elseif package:config("precision") == "long" then
            table.insert(configs, "-DENABLE_LONG_DOUBLE=ON")
        end
        if package:config("thread") == "fftw" then
            table.insert(configs, "-DENABLE_THREADS=ON")
        elseif package:config("thread") == "openmp" then
            table.insert(configs, "-DENABLE_OPENMP=ON")
        end

        local simds = import("core.base.hashset").of("sse", "sse2", "avx", "avx2")
        local simd = package:config("simd")
        if simd ~= "none" and simds:has(simd) then
            table.insert(configs, "-DENABLE_" .. string.upper(simd) .. "=ON")
        end

        local opt = {}
        if package:is_plat("mingw") then
            opt.cxflags = "-DWITH_OUR_MALLOC"
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "fftw3.pdb"), dir)
        end
    end)

    on_install("linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
        end
        if package:config("precision") == "float" then
            table.insert(configs, "--enable-float")
        elseif package:config("precision") == "quad" then
            table.insert(configs, "--enable-quad-precision")
        elseif package:config("precision") == "long" then
            table.insert(configs, "--enable-long-double")
        end
        if package:config("thread") == "fftw" then
            table.insert(configs, "--enable-threads")
        elseif package:config("thread") == "openmp" then
            table.insert(configs, "--enable-openmp")
        end
        if package:config("enable_mpi") then
            table.insert(configs, "--enable-mpi")
        end
        if package:config("simd") ~= "none" then
            table.insert(configs, "--enable-" .. package:config("simd"))
        end
        import("lib.detect.find_tool")
        local fortran = find_tool("gfortran")
        if fortran then
            table.insert(configs, "F77=" .. fortran.program)
        else
            table.insert(configs, "--disable-fortran")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        local precision_map = {
            float = "f",
            long = "l",
            quad = "q",
        }

        local name = precision_map[package:config("precision")] or ""
        local fn = "fftw" .. name .. "_execute"
        assert(package:has_cfuncs(fn, {includes = "fftw3.h"}))
    end)
