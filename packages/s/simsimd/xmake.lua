package("simsimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/simsimd-faster-scipy/")
    set_description("Vector Similarity Functions 3x-200x Faster than SciPy and NumPy — for Python, JavaScript, Rust, and C 11, supporting f64, f32, f16, i8, and binary vectors using SIMD for both x86 AVX2 & AVX-512 and Arm NEON & SVE 📐")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/SimSIMD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/SimSIMD.git")

    add_versions("v3.9.0", "8e79b628ba89beebc7c4c853323db0e10ebb6f85bcda2641e1ebaf77cfbda7f9")

    on_install(function (package)
        os.cp("include/simsimd/", package:installdir("include"))
    end)

    on_test(function (package)
        local cxflags
        if not package:is_plat("iphoneos") then
            cxflags = {"-march=native"}
        end
        if package:is_plat("linux", "macosx") and package:config("cc") == "gcc" then
            table.insert(cxflags, "-fmax-errors=1")
            table.insert(cxflags, "-Wno-tautological-constant-compare")
        else
            table.insert(cxflags, "-pedantic")
            table.insert(cxflags, "-ferror-limit=1")
        end

        assert(package:has_cfuncs(
            "simsimd_capabilities",
            {includes = "simsimd/simsimd.h",
            configs = {languages = "c11", cxflags = cxflags, {force = true}}}))
        end)
