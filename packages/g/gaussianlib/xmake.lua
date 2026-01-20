package("gaussianlib")
    set_kind("library", {headeronly = true})

    set_description("Basic linear algebra C++ library for 2D and 3D applications")
    set_homepage("https://github.com/LukasBanana/GaussianLib")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/LukasBanana/GaussianLib.git")

    add_versions("2024.12.31", "d988f87f2bb20a3c41fa1f20c2d0f132ae7545c5")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Gauss/Gauss.h>
            #include <iostream>
            static const Gs::Real pi = Gs::Real(3.141592654);
            
            void test() {
                Gs::Vector4 a(1, 2, 3, 4), b(-12, 0.5f, 0, 1);
                const Gs::Vector2 c(42, 19);
                Gs::Matrix<double, 3, 4> A;
                Gs::Matrix<double, 4, 3> B;
            }
        ]]}, {configs = {languages = "cxx11"}}))

    end)
