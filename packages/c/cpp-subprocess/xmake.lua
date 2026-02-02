package("cpp-subprocess")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/arun11299/cpp-subprocess")
    set_description("Subprocessing with modern C++.")
    set_license("MIT")

    set_urls("https://github.com/arun11299/cpp-subprocess.git")
    add_versions("2025.11.10", "8d93da7a9e10cae3ce5888af92f26fbd7871d61e")
    add_versions("2024.01.25", "4025693decacaceb9420efedbf4967a04cb028e7")

    add_links("cpp-subprocess")

    on_install(function (package)
        os.cp("subprocess.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <subprocess.hpp>
            #include <iostream>
            namespace sp = subprocess;
            int main() {
                auto obuf = sp::check_output({"ls", "-l"});
                std::cout << "Data : " << obuf.buf.data() << std::endl;
                std::cout << "Data len: " << obuf.length << std::endl;
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
