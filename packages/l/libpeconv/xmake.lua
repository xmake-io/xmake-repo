package("libpeconv")
    set_homepage("https://hasherezade.github.io/libpeconv")
    set_description("A library to load, manipulate, dump PE files. See also: https://github.com/hasherezade/libpeconv_tpl")

    add_urls("https://github.com/hasherezade/libpeconv.git")
    add_versions("2023.05.31", "709a9b40fa6420c6cd7aa1145b0ff1a154858358")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("kernel32", "ntdll")
    end

    on_install("windows", "mingw", function (package)
        local configs = {"-DPECONV_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("libpeconv/CMakeLists.txt", "/MT", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory ( run_pe )", "", {plain = true})
        io.replace("CMakeLists.txt", "add_dependencies ( run_pe libpeconv )", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                size_t size = 0;
                BYTE* my_pe = peconv::load_pe_executable(NULL, size);
                if (my_pe) {
                    peconv::set_main_module_in_peb((HMODULE)my_pe);
                }
            }
        ]]}, {includes = {"peconv.h"}}))
    end)
