package("cpp-dump")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/philip82148/cpp-dump")
    set_description("A C++ library for debugging purposes that can print any variable, even user-defined types.")
    set_license("MIT")

    add_urls("https://github.com/philip82148/cpp-dump/archive/refs/tags/$(version).tar.gz",
             "https://github.com/philip82148/cpp-dump.git")

    add_versions("v0.7.0", "b27a0854a405aa10619f341f66e26a6c39dca1ad41a26dd4fa6d86ad6752c4f8")
    add_versions("v0.6.0", "22bc5fafa22ac7c1e99db8824fdabec4af6baabed0c8b7cc80a0205dfb550414")
    add_versions("v0.5.0", "31fa8b03c9ee820525137be28f37b36e2abe7fd91df7d67681cb894db2230fe6")

    on_load(function (package)
        if package:gitref() or package:version():ge("0.7.0") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:gitref() or package:version():ge("0.7.0") then
            io.replace("CMakeLists.txt", "if(IS_TOP_LEVEL)", "if(0)", {plain = true})
            import("package.tools.cmake").install(package)
        else
            os.cp("hpp", package:installdir("include/cpp-dump"))
            os.cp("dump.hpp", package:installdir("include/cpp-dump"))
        end
    end)

    on_test(function (package)
        local includes = "cpp-dump/dump.hpp"
        if package:gitref() or package:version():ge("0.7.0") then
            includes = "cpp-dump.hpp"
        end

        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::vector<std::vector<int>> my_vector{{3, 5, 8, 9, 7}, {9, 3, 2, 3, 8}};
                cpp_dump(my_vector);
            }
        ]]}, {configs = {languages = "c++17"}, includes = includes}))
    end)
