package("dune-common")

    set_homepage("https://dune-project.org/")
    set_description("DUNE, the Distributed and Unified Numerics Environment is a modular toolbox for solving partial differential equations with grid-based methods.")
    set_license("GPL-2.0")

    add_urls("https://dune-project.org/download/$(version)/dune-common-$(version).tar.gz")
    add_versions("2.8.0", "c9110b3fa350547c5e962c961905c6c67680471199ca41ed680489a0f30ffce9")

    add_configs("python", {description = "Enable the python interface.", default = false, type = "boolean"})

    add_deps("cmake")
    add_links("dunecommon")
    on_load("macosx", "linux", function (package)
        if package:config("python") then
            package:add("deps", "python 3.x")
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDUNE_ENABLE_PYTHONBINDINGS=" .. (package:config("python") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dune/common/std/make_array.hh>
            void test() {
                auto array = Dune::Std::make_array(1, 2);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
