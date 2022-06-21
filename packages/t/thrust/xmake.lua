package("thrust")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NVIDIA/thrust")
    set_description("The C++ parallel algorithms library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/NVIDIA/thrust/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA/thrust.git")
    add_versions("1.17.0", "b02aca5d2325e9128ed9d46785b8e72366f758b873b95001f905f22afcf31bbf")

    add_deps("cmake")
    add_deps("cuda", {system = true})
    
    on_install(function (package)
        os.cp("thrust", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <thrust/version.h>
            #include <iostream>

            void test() {
                int major = THRUST_MAJOR_VERSION;
                int minor = THRUST_MINOR_VERSION;

                std::cout << "Thrust v" << major << "." << minor << std::endl;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
