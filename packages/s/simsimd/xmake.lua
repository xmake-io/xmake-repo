package("simsimd")
    set_kind("library", {headeronly = true})
    set_homepage("https://ashvardanian.com/posts/simsimd-faster-scipy/")
    set_description("Vector Similarity Functions 3x-200x Faster than SciPy and NumPy")
    set_license("Apache-2.0")

    add_urls("https://github.com/ashvardanian/SimSIMD/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ashvardanian/SimSIMD.git")

    add_versions("v4.3.2", "0732603a0680a4b9c70abe0b59de011447ad7db0e0631c2f7c307c0135aa4d43")
    add_versions("v4.3.1", "d3c54c5b27f8bbb161c8523c47ddc98bfeb75cac17066c959f42ebe78c518b0f")
    add_versions("v3.9.0", "8e79b628ba89beebc7c4c853323db0e10ebb6f85bcda2641e1ebaf77cfbda7f9")

    on_install(function (package)
        os.cp("include", package:installdir())
        if not package:has_ctypes("_Float16") then
            package:add("defines", "SIMSIMD_NATIVE_F16=0")
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("simsimd/simsimd.h"))
    end)
