package("simsimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/simsimd-faster-scipy/")
    set_description("Vector Similarity Functions 3x-200x Faster than SciPy and NumPy")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/SimSIMD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/SimSIMD.git")

    add_versions("v3.9.0", "8e79b628ba89beebc7c4c853323db0e10ebb6f85bcda2641e1ebaf77cfbda7f9")

    on_install(function (package)
        io.replace("include/simsimd/spatial.h", "_vec = vdotq_s32", "_vec = (int32x4_t)vdotq_s32", {plain = true})
        os.cp("include", package:installdir())
        if not package:has_ctypes("_Float16") then
            package:add("defines", "SIMSIMD_NATIVE_F16=0")
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("simsimd/simsimd.h"))
    end)
