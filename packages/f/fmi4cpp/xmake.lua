package("fmi4cpp")
    set_homepage("https://github.com/NTNU-IHB/FMI4cpp")
    set_description("A cross-platform FMI 2.0 implementation written in modern C++")

    add_urls("https://github.com/NTNU-IHB/FMI4cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NTNU-IHB/FMI4cpp.git")
    add_versions("0.8.0", "78616e9c86a23137a8d3a113fe6420207c3f9ea46442e1c75a01215eb2693bb7")

    add_patches("0.8.0", path.join(os.scriptdir(), "patches", "0.8.0", "clang_fix.patch"), "dacd893e90298763223b21b0054dad6d6a82c7c36ab0d3d0cc1984a342c01f9f")
    add_patches("0.8.0", path.join(os.scriptdir(), "patches", "0.8.0", "win32_zlib.patch"), "99d14ebf2f1d7b848ab5fc5b659826d50429e59810f13b25953fddfc8f4313b7")

    add_deps("cmake", "boost", "libzip")

    on_install("linux", function (package)
        local configs = {
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release")
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream> 
            #include <fmi4cpp/fmi4cpp.hpp>

            using namespace fmi4cpp;

            const double stop = 10.0;
            const double stepSize = 0.0001;
            
            void test(int argc, char** argv) {
                fmi2::fmu fmu("path/to/fmu.fmu");

                auto cs_fmu = fmu.as_cs_fmu();
                auto me_fmu = fmu.as_me_fmu();

                auto cs_md = cs_fmu->get_model_description(); //smart pointer to a cs_model_description instance
                std::cout << "model_identifier=" << cs_md->model_identifier << std::endl;

                auto me_md = me_fmu->get_model_description(); //smart pointer to a me_model_description instance
                std::cout << "model_identifier=" << me_md->model_identifier << std::endl;

                auto var = cs_md->get_variable_by_name("my_var").as_real();
                std::cout << "Name=" << var.name() <<  ", start=" << var.start().value_or(0) << std::endl;

                auto slave = cs_fmu->new_instance();

                slave->setup_experiment();
                slave->enter_initialization_mode();
                slave->exit_initialization_mode();

                double t;
                double value;
                auto vr = var.valueReference();
                while ( (t = slave->get_simulation_time()) <= stop) {

                    if (!slave->step(stepSize)) {
                        std::cerr << "Error! step() returned with status: " << to_string(slave->last_status()) << std::endl;
                        break;
                    }

                    if (!slave->read_real(vr, value)) {
                        std::cerr << "Error! step() returned with status: " << to_string(slave->last_status()) << std::endl;
                        break;
                    }
                    std::cout << "t=" << t << ", " << var.name() << "=" << value << std::endl;

                }

                slave->terminate();
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
