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

        package:add("links", "sleef")
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
        -- Remove --target from NEON32 flags on Android ARM32
        if package:is_cross() and package:is_plat("android") and package:arch():find("^arm") and not package:arch():find("arm64") then
            io.replace("Configure.cmake",
                'set(CLANG_FLAGS_ENABLE_NEON32 "--target=arm-linux-gnueabihf;-mcpu=cortex-a8")',
                'set(CLANG_FLAGS_ENABLE_NEON32 "--target=arm-linux-gnueabihf;-mcpu=cortex-a8")\nif(ANDROID)\n  list(FILTER CLANG_FLAGS_ENABLE_NEON32 EXCLUDE REGEX "^--target")\nendif()',
                {plain = true})
        end

        if package:is_plat("iphoneos") then
            -- iOS architecture detection fix
            io.replace("Configure.cmake",
                'if(CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND CMAKE_OSX_ARCHITECTURES MATCHES "^(x86_64|arm64)$")',
                'if((CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR CMAKE_SYSTEM_NAME STREQUAL "iOS") AND CMAKE_OSX_ARCHITECTURES MATCHES "^(x86_64|arm64)$")',
                {plain = true})

            -- SVE crashes Apple Clang on iPhoneOS
            io.replace("Configure.cmake",
                'if(SLEEF_ARCH_AARCH64 AND NOT SLEEF_DISABLE_SVE AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin")',
                'if(SLEEF_ARCH_AARCH64 AND NOT SLEEF_DISABLE_SVE AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND NOT CMAKE_SYSTEM_NAME STREQUAL "iOS")',
                {plain = true})
        end

        if package:is_plat("mingw") then
            -- Disable alias attr on mingw (PE/COFF)
            io.replace("Configure.cmake",
                'if (COMPILER_SUPPORTS_WEAK_ALIASES)',
                'if (COMPILER_SUPPORTS_WEAK_ALIASES AND NOT (WIN32 AND CMAKE_C_COMPILER_ID STREQUAL "GNU"))',
                {plain = true})

            --Remove __stdcall from EXPORT on mingw (matches SLEEF_IMPORT)
            io.replace("src/common/misc.h",
                '#define EXPORT __stdcall __declspec(dllexport)',
                '#define EXPORT __declspec(dllexport)',
                {plain = true})
        end

        if package:is_plat("wasm") then
            -- Remove -msse2 -mfpmath=sse on Emscripten (wasm)
            io.replace("Configure.cmake",
                'if (SLEEF_ARCH_X86 AND SLEEF_ARCH_32BIT)',
                'if (SLEEF_ARCH_X86 AND SLEEF_ARCH_32BIT AND NOT CMAKE_SYSTEM_NAME STREQUAL "Emscripten")',
                {plain = true})

            -- Substitute FP_FAST_FMA defines for -mavx2;-mfma on Emscripten
            io.replace("Configure.cmake",
                '  set(CLANG_FLAGS_ENABLE_PURECFMA_SCALAR "-mavx2;-mfma")',
                '  if(NOT CMAKE_SYSTEM_NAME STREQUAL "Emscripten")\n    set(CLANG_FLAGS_ENABLE_PURECFMA_SCALAR "-mavx2;-mfma")\n  else()\n    set(CLANG_FLAGS_ENABLE_PURECFMA_SCALAR "-DFP_FAST_FMA;-DFP_FAST_FMAF")\n  endif()',
                {plain = true})
        end

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

        if package:is_plat("windows") and package:is_arch("arm.*") then
            -- CMake MATCHES is case-sensitive; ARM64 != arm64
            io.replace("Configure.cmake",
                'elseif(SLEEF_TARGET_PROCESSOR MATCHES "aarch64|arm64")',
                'elseif(SLEEF_TARGET_PROCESSOR MATCHES "aarch64|arm64|ARM64")',
                {plain = true})
        end

        if package:is_cross() then
            -- Build native host tools first
            local native_build_dir = path.join(package:builddir(), "sleef_native_host")
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

            if package:is_plat("windows") and package:is_arch("arm*") then
                table.insert(configs, "-DSLEEF_DISABLE_SVE=ON")
                -- Override cmake auto-detected target processor for cross-build
                table.insert(configs, "-DSLEEF_TARGET_PROCESSOR=ARM64")
            else
                table.insert(configs, "-DSLEEF_DISABLE_SVE=" .. (package:config("sve") and "OFF" or "ON"))
            end

            table.insert(configs, "-DNATIVE_BUILD_DIR=" .. path.absolute(native_build_dir))
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Sleef_sin_u10", {includes = "sleef.h"}))
    end)
