package("eigen")
    set_homepage("https://eigen.tuxfamily.org/")
    set_description("C++ template library for linear algebra")
    set_license("MPL-2.0")

    add_urls("https://gitlab.com/libeigen/eigen/-/archive/$(version)/eigen-$(version).tar.bz2",
             "https://gitlab.com/libeigen/eigen.git")

    add_versions("3.3.7", "685adf14bd8e9c015b78097c1dc22f2f01343756f196acdc76a678e1ae352e11")
    add_versions("3.3.8", "0215c6593c4ee9f1f7f28238c4e8995584ebf3b556e9dbf933d84feb98d5b9ef")
    add_versions("3.3.9", "0fa5cafe78f66d2b501b43016858070d52ba47bd9b1016b0165a7b8e04675677")
    add_versions("3.4.0", "b4c198460eba6f28d34894e3a5710998818515104d6e74e5cc331ce31e46e626")
    add_versions("3.4.1", "8bb7280b7551bf06418d11a9671fdf998cb927830cf21589b394382d26779821")

    add_configs("blas", {description = "Provide a Eigen-implemented BLAS.", default = false, type = "boolean"})
    add_configs("lapack", {description = "Provide a Eigen-implemented LAPACK.", default = false, type = "boolean"})
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::eigen3")
    elseif is_plat("linux") then
        add_extsources("pacman::eigen3", "apt::libeigen3-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::eigen")
    end

    add_deps("cmake")
    add_includedirs("include", "include/eigen3")
    on_load(function (package)
        if not package:config("blas") and not package:config("lapack") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        if not package:config("blas") then
            io.replace("CMakeLists.txt", "add_subdirectory(blas", "#", {plain = true})
        end
        if not package:config("lapack") then
            io.replace("CMakeLists.txt", "add_subdirectory(lapack", "#", {plain = true})
        end
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DEIGEN_BUILD_DEMOS=OFF",
            "-DEIGEN_BUILD_DOC=OFF",
        }
        import("package.tools.cmake").install(package, configs)

        if not os.isfile(package:installdir("include/eigen3/Eigen/Dense")) then
            os.vcp("unsupported/Eigen", package:installdir("include/eigen3/unsupported"))
            os.vcp("Eigen", package:installdir("include/eigen3"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Eigen/Dense>
            using Eigen::MatrixXd;
            void test() {
                MatrixXd m(2,2);
                m(0,0) = 3;
                m(1,0) = 2.5;
                m(0,1) = -1;
                m(1,1) = m(1,0) + m(0,1);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
