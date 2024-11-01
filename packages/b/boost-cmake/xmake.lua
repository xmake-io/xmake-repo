package("boost-cmake")
    set_homepage("https://www.boost.org/")
    set_description("Collection of portable C++ source libraries.")
    set_license("BSL-1.0")

    set_urls("https://github.com/boostorg/boost/releases/download/boost-$(version)/boost-$(version)-cmake.7z")

    add_versions("1.86.0", "ee6e0793b5ec7d13e7181ec05d3b1aaa23615947295080e4b9930324488e078f")

    includes(path.join(os.scriptdir(), "libs.lua"))
    for libname, _ in pairs(get_libs()) do
        add_configs(libname, {description = "Enable " .. libname .. " library.", default = (libname == "filesystem"), type = "boolean"})
    end

    add_deps("cmake")

    on_load(function (package)
        import("cmake.load")(package)
    end)

    on_install(function (package)
        import("cmake.install")(package)
    end)

    on_test(function (package)
        if package:config("filesystem") then
            assert(package:check_cxxsnippets({test = [[
                #include <boost/filesystem.hpp>
                #include <iostream>
                static void test() {
                    boost::filesystem::path path("/path/to/directory");
                    if (boost::filesystem::exists(path)) {
                        std::cout << "Directory exists" << std::endl;
                    } else {
                        std::cout << "Directory does not exist" << std::endl;
                    }
                }
            ]]}, {configs = {languages = "c++14"}}))
        end
    end)
