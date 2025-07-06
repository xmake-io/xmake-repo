package("nifly")
    set_homepage("https://github.com/ousnius/nifly")
    set_description("C++ NIF library for the Gamebryo/NetImmerse File Format")
    set_license("GPL-3.0")

    add_urls("https://github.com/ousnius/nifly.git")
    add_versions("2024.09.28", "a6bbbeb92be1fc97d106759a231a96e962e8cfe2")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("half", "miniball")

    on_install("windows", "linux", "bsd", "macos", "android", "iphoneos", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                nifly::NifFile nif;
                nif.Load("non_existant.nif");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "nifly/NifFile.hpp"}))
    end)
