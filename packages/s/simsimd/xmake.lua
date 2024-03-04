package("simsimd")
    set_kind("library")
    set_homepage("https://ashvardanian.com/posts/simsimd-faster-scipy/")
    set_description("Vector Similarity Functions 3x-200x Faster than SciPy and NumPy — for Python, JavaScript, Rust, and C 11, supporting f64, f32, f16, i8, and binary vectors using SIMD for both x86 AVX2 & AVX-512 and Arm NEON & SVE 📐")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/SimSIMD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/SimSIMD.git")

    add_versions("v3.9.0", "8e79b628ba89beebc7c4c853323db0e10ebb6f85bcda2641e1ebaf77cfbda7f9")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        os.cp("include", package:installdir())
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("simsimd_capabilities", {includes = "simsimd/simsimd.h"}))
        assert(package:has_cxxfuncs("simsimd_capabilities", {includes = "simsimd/simsimd.h", configs = {languages = "c++17"}}))
    end)
