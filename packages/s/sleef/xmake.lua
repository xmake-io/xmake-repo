	package("sleef")
		set_homepage("https://sleef.org/")
		set_description("SIMD Library for Evaluating Elementary Functions, vectorized libm and DFT")
		set_license("BSL-1.0")

		add_urls("https://github.com/shibatch/sleef/archive/refs/tags/$(version).tar.gz",
				 "https://github.com/shibatch/sleef.git")

		add_versions("3.9.0", "af60856abac08a3b5e72a8d156dd71fec1f7ac23de8ee67793f45f9edcdf0908")

    add_configs("shared",          {description = "Build shared libraries", default = true, type = "boolean"})
    add_configs("lto",             {description = "Enable LTO on GCC or ThinLTO on clang", default = false, type = "boolean"})
    add_configs("dft",             {description = "Build libsleefdft", default = false, type = "boolean"})
    add_configs("quad",            {description = "Build libsleefquad", default = false, type = "boolean"})
    add_configs("gnuabi",          {description = "Build libsleefgnuabi", default = true, type = "boolean"})
    add_configs("scalar",          {description = "Build libsleefscalar", default = false, type = "boolean"})
    add_configs("inline_headers",  {description = "Build header for inlining whole SLEEF functions", default = false, type = "boolean"})

    add_configs("dft_stream",      {description = "Utilize streaming instructions in DFT", default = false, type = "boolean"})

    add_configs("show_config",     {description = "Show SLEEF configuration status messages", default = true, type = "boolean"})
    add_configs("asan",            {description = "Enable address sanitizing on all targets.", default = false, type = "boolean"})

    add_configs("altdiv",          {description = "Enable alternative division method (AArch64 only)", default = false, type = "boolean"})
    add_configs("altsqrt",         {description = "Enable alternative sqrt method (AArch64 only)", default = false, type = "boolean"})

    add_configs("cuda",            {description = "Enable CUDA", default = false, type = "boolean"})

    add_configs("build_with_libm", {description = "build libsleef with libm, can turn off on Windows to solve mutiple math functions issue", default = true, type = "boolean"})

    add_configs("float128",        {description = "Enable float128 support", default = true, type = "boolean"})

    -- SIMD extensions (SLEEF auto-detects by default; set false to explicitly disable)
    add_configs("sse2",            {description = "SSE2 support", default = true, type = "boolean"})
    add_configs("sse4",            {description = "SSE4 support", default = true, type = "boolean"})
    add_configs("fma4",            {description = "FMA4 support", default = true, type = "boolean"})
    add_configs("avx",             {description = "AVX support", default = true, type = "boolean"})
    add_configs("avx2",            {description = "AVX2 support", default = true, type = "boolean"})
    add_configs("avx512f",         {description = "AVX512F support", default = true, type = "boolean"})
    add_configs("sve",             {description = "SVE support", default = true, type = "boolean"})
    add_configs("vsx",             {description = "VSX support", default = true, type = "boolean"})
    add_configs("vsx3",            {description = "VSX3 support", default = true, type = "boolean"})
    add_configs("vxe",             {description = "VXE support", default = true, type = "boolean"})
    add_configs("vxe2",            {description = "VXE2 support", default = true, type = "boolean"})
    add_configs("rvvm1",           {description = "RVVM1 support", default = true, type = "boolean"})
    add_configs("rvvm2",           {description = "RVVM2 support", default = true, type = "boolean"})

    add_configs("openmp",          {description = "Enable OpenMP", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if not package:config("shared") then
            package:add("defines", "SLEEF_STATIC_LIBS")
        end

        if package:config("dft") then
            package:add("links", "sleefdft")
        end
        if package:config("quad") then
            package:add("links", "sleefquad")
        end
        if package:config("gnuabi") then
            package:add("links", "sleefgnuabi")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),

            -- Core options
            "-DSLEEF_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"),
            "-DSLEEF_BUILD_DFT=" .. (package:config("dft") and "ON" or "OFF"),
            "-DSLEEF_BUILD_QUAD=" .. (package:config("quad") and "ON" or "OFF"),
            "-DSLEEF_BUILD_GNUABI_LIBS=" .. (package:config("gnuabi") and "ON" or "OFF"),
            "-DSLEEF_BUILD_SCALAR_LIB=" .. (package:config("scalar") and "ON" or "OFF"),
            "-DSLEEF_BUILD_INLINE_HEADERS=" .. (package:config("inline_headers") and "ON" or "OFF"),

            "-DSLEEFDFT_ENABLE_STREAM=" .. (package:config("dft_stream") and "ON" or "OFF"),

            "-DSLEEF_SHOW_CONFIG=" .. (package:config("show_config") and "ON" or "OFF"),
            "-DSLEEF_ASAN=" .. (package:config("asan") and "ON" or "OFF"),

            "-DSLEEF_ENABLE_ALTDIV=" .. (package:config("altdiv") and "ON" or "OFF"),
            "-DSLEEF_ENABLE_ALTSQRT=" .. (package:config("altsqrt") and "ON" or "OFF"),

            "-DSLEEF_ENABLE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"),

            "-DSLEEF_BUILD_WITH_LIBM=" .. (package:config("build_with_libm") and "ON" or "OFF"),

            "-DSLEEF_DISABLE_FLOAT128=" .. (package:config("float128") and "OFF" or "ON"),

            -- SIMD extensions (disable when config is false)
            "-DSLEEF_DISABLE_SSE2=" .. (package:config("sse2") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_SSE4=" .. (package:config("sse4") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_FMA4=" .. (package:config("fma4") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_AVX=" .. (package:config("avx") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_AVX2=" .. (package:config("avx2") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_AVX512F=" .. (package:config("avx512f") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_SVE=" .. (package:config("sve") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_VSX=" .. (package:config("vsx") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_VSX3=" .. (package:config("vsx3") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_VXE=" .. (package:config("vxe") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_VXE2=" .. (package:config("vxe2") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_RVVM1=" .. (package:config("rvvm1") and "OFF" or "ON"),
            "-DSLEEF_DISABLE_RVVM2=" .. (package:config("rvvm2") and "OFF" or "ON"),

            "-DSLEEF_DISABLE_OPENMP=" .. (package:config("openmp") and "OFF" or "ON"),

            "-DSLEEF_BUILD_TESTS=OFF",
            "-DSLEEF_ENABLE_TESTER4=OFF",
            "-DSLEEF_DISABLE_FFTW=ON",
            "-DSLEEF_DISABLE_MPFR=ON",
            "-DSLEEF_ENABLE_TLFLOAT=OFF",
            "-DSLEEF_DISABLE_SSL=ON",
        }

        if package:is_cross() then
            -- Build native host tools first
            local native_build_dir = path.join(package:buildir(), "sleef_native_host")
            local native_configs = {
                "-DCMAKE_BUILD_TYPE=Release",
                "-DBUILD_SHARED_LIBS=OFF",
                "-DSLEEF_BUILD_DFT=OFF",
                "-DSLEEF_BUILD_QUAD=OFF",
                "-DSLEEF_BUILD_GNUABI_LIBS=OFF",
                "-DSLEEF_BUILD_SCALAR_LIB=OFF",
                "-DSLEEF_BUILD_INLINE_HEADERS=OFF",
                "-DSLEEF_BUILD_TESTS=OFF",
                "-DSLEEF_BUILD_BENCH=OFF",
                "-DSLEEF_ENABLE_TESTER=OFF",
                "-DSLEEF_ENABLE_TESTER4=OFF",
                "-DSLEEF_DISABLE_FFTW=ON",
                "-DSLEEF_DISABLE_MPFR=ON",
                "-DSLEEF_ENABLE_TLFLOAT=OFF",
                "-DSLEEF_DISABLE_SSL=ON",
            }
            os.mkdir(native_build_dir)
            os.exec("cmake -S . -B " .. native_build_dir .. " " .. table.concat(native_configs, " "))
            os.exec("cmake --build " .. native_build_dir .. " --target mkrename mkrename_gnuabi mkmasked_gnuabi mkdisp mkalias addSuffix")

            table.insert(configs, "-DNATIVE_BUILD_DIR=" .. path.absolute(native_build_dir))
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Sleef_sin_u10", {includes = "sleef.h"}))
    end)
