package("fftw")
    set_homepage("http://fftw.org/")
    set_description("A C subroutine library for computing the discrete Fourier transform (DFT) in one or more dimensions.")
    set_license("GPL-2.0")

    add_urls("http://fftw.org/fftw-$(version).tar.gz")

    add_versions("3.3.8", "6113262f6e92c5bd474f2875fa1b01054c4ad5040f6b0da7c03c98821d9ae303")
    add_versions("3.3.9", "bf2c7ce40b04ae811af714deb512510cc2c17b9ab9d6ddcf49fe4487eea7af3d")
    add_versions("3.3.10", "56c932549852cddcfafdab3820b0200c7742675be92179e59e6215b340e26467")

    local default_optimizations = {
        float = {"sse", "avx"},
        double = {"sse2", "avx"},
        long = {},
        quad = {}
    }

    add_configs("tools", {description = "Build tools.", default = false, type = "boolean"})

    -- for backward compatibility
    add_configs("precision", {description = "Float number precision. (deprecated)", default = nil, type = "string", values = {"float", "double", "quad", "long"}})
    add_configs("simd", {description = "SIMD instruction sets used. (deprecated)", default = nil, type = "string", values = {"none", "sse", "sse2", "avx", "avx2", "avx512", "avx-128-fma", "kcvi", "altivec", "vsx", "neon", "generic-simd128", "generic-simd256"}})

    add_configs("precisions", {description = "The floating point precision to enable. (float|double|quad|long)", default = {"float", "double"}, type = "table"})
    add_configs("optimizations", {description = "Optimization options enabled for each precision target.", default = default_optimizations, type = "table"})

    add_configs("thread", {description = "Thread model used.", default = "fftw", type = "string", values = {"none", "fftw", "openmp"}})
    add_configs("enable_mpi", {description = "Enable MPI support.", default = false, type = "boolean"})

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

        -- for backward compatibility
        if package:config("precision") then
            local precs = package:config("precisions")
            table.insert(precs, package:config("precision"))
            package:config_set("precisions", precs)
        end
        if package:config("simd") then
            local optis = package:config("optimizations")
            for target, _ in pairs(package:config("optimizations")) do
                table.insert(optis[target], package:config("simd"))
            end
            package:config_set("optimizations", optis)
        end
    end)

    on_install(function (package)
        for _, prec in ipairs(package:config("precisions")) do
            local configs = {
                "-DBUILD_TESTS=OFF",
                "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
                "--fresh"
            }

            table.insert(configs, "-DWITH_COMBINED_THREADS=" .. (package:config("shared") and "ON" or "OFF"))

            if package:config("thread") == "fftw" then
                table.insert(configs, "-DENABLE_THREADS=ON")
            elseif package:config("thread") == "openmp" then
                table.insert(configs, "-DENABLE_OPENMP=ON")
            end

            local opt = { builddir = "build" }
            if package:is_plat("mingw") then
                opt.cxflags = "-DWITH_OUR_MALLOC"
            end

            if prec == "float" then
                table.insert(configs, "-DENABLE_FLOAT=ON")
            elseif prec == "quad" then
                table.insert(configs, "-DENABLE_QUAD_PRECISION=ON")
            elseif prec == "long" then
                table.insert(configs, "-DENABLE_LONG_DOUBLE=ON")
            end

            local simds = {"sse", "sse2", "avx", "avx2"}
            for simd in ipairs(simds) do
                if table.contains(package:config("optimizations")[prec], simd) then
                    table.insert(configs, "-DENABLE_" .. string.upper(simd) .. "=ON")
                end
            end

            import("package.tools.cmake").install(package, configs, opt)

            if package:is_plat("windows") and package:is_debug() then
                local dir = package:installdir(package:config("shared") and "bin" or "lib")
                os.trycp(path.join(package:builddir(), "fftw3.pdb"), dir)
                os.trycp(path.join(package:builddir(), "fftw3f.pdb"), dir)
                os.trycp(path.join(package:builddir(), "fftw3l.pdb"), dir)
                os.trycp(path.join(package:builddir(), "fftw3q.pdb"), dir)
            end
        end
    end)

    on_install("linux", function (package)
        import("lib.detect.find_tool")

        for _, prec in ipairs(package:config("precisions")) do
            local configs = {
                "--disable-dependency-tracking",
                "--disable-doc"
            }

            if package:config("thread") == "fftw" then
                table.insert(configs, "--enable-threads")
            elseif package:config("thread") == "openmp" then
                table.insert(configs, "--enable-openmp")
            end
            if package:config("enable_mpi") then
                table.insert(configs, "--enable-mpi")
            end

            local fortran = find_tool("gfortran")
            if fortran then
                table.insert(configs, "F77=" .. fortran.program)
            else
                table.insert(configs, "--disable-fortran")
            end

            if prec == "float" then
                table.insert(configs, "--enable-float")
            elseif prec == "quad" then
                table.insert(configs, "--enable-quad-precision")
            elseif prec == "long" then
                table.insert(configs, "--enable-long-double")
            end

            local optis = {
                "sse", "sse2", "avx", "avx2", "avx512", "avx-128-fma", 
                "kcvi", "altivec", "vsx", "neon", 
                "armv8-pmccntr-el0", "armv8-cntvct-el0", "armv7a-cntvct", "armv7a-pmccntr", 
                "generic-simd128", "generic-simd256", 
                "mips-zbus-timer", "fma"
            }
            for opti in ipairs(optis) do
                if table.contains(package:config("optimizations")[prec], opti) then
                    table.insert(configs, "--enable-" .. opti)
                end
            end

            if not package:config("tools") then
                io.replace("Makefile.in", "tools ", "", {plain = true})
            end
            io.replace("Makefile.in", "tests ", "", {plain = true})

            import("package.tools.autoconf").install(package, configs)

            os.vrunv("make distclean")
        end
    end)

    on_test(function (package)
        local precision_map = {
            float = "f",
            long = "l",
            quad = "q",
        }

        for _, prec in ipairs(package:config("precisions")) do
            local name = precision_map[prec] or ""
            local fn = "fftw" .. name .. "_execute"
            assert(package:has_cfuncs(fn, {includes = "fftw3.h"}))
        end
    end)
