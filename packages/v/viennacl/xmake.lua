package("viennacl")

    set_homepage("http://viennacl.sourceforge.net/")
    set_description("ViennaCL is a free open-source linear algebra library for computations on many-core architectures (GPUs, MIC) and multi-core CPUs.")
    set_license("MIT")

    add_urls("https://sourceforge.net/projects/viennacl/files/$(version).zip", {version = function (version)
        return format("%s.%s.x/ViennaCL-%s", version:major(), version:minor(), version)
    end})
    add_versions("1.7.1", "1e9ffaa9d1dd22202cbd10ec8a8450184bceb41bbd90ebe2effd50be2015a7f6")

    add_deps("cmake")
    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory", "#", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                viennacl::vector<float> vec1(4);
                viennacl::vector<float> vec2(4);
                float res = viennacl::linalg::inner_prod(vec1, vec2);
            }
        ]]}, {configs = {languages = "c++11"},
              includes = {"viennacl/vector.hpp", "viennacl/linalg/inner_prod.hpp"}}))
    end)
