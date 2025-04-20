package("pprint")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/pprint")
    set_description("Pretty Printer for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/pprint.git")

    add_versions("2020.2.20", "0ee09c8d8a9eebc944d07ac69e3b86d41f2304df")

    add_deps("cmake")
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=on")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=off")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({
            test = [[
            #include <pprint/pprint.hpp>
            void test() {
                pprint::PrettyPrinter printer;
                printer.print(5);
                printer.print(3.14f);
                printer.print(2.718);
                printer.print(true);
                printer.print('x');
                printer.print("Hello, 世界");
                printer.print(nullptr);
            }
            ]]},
            {configs = {languages = "c++17"}
        }))
    end)
