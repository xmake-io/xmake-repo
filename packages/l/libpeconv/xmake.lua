package("libpeconv")
    set_homepage("https://hasherezade.github.io/libpeconv")
    set_description("A library to load, manipulate, dump PE files. See also: https://github.com/hasherezade/libpeconv_tpl")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/hasherezade/libpeconv.git")

    add_versions("2024.09.06", "e4841b678c14a2e735e59354aa1b0f6755339cab")
    add_versions("2023.05.31", "709a9b40fa6420c6cd7aa1145b0ff1a154858358")

    add_configs("unicode", {description = "Enable Unicode support.", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_syslinks("kernel32", "ntdll")

    add_deps("cmake")

    on_install("windows|x64", "windows|x86", "mingw", "msys", function (package)
        if package:config("unicode") then
            package:add("defines", "UNICODE", "_UNICODE")
        end

        local configs = {"-DPECONV_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DPECONV_UNICODE=" .. (package:config("unicode") and "ON" or "OFF"))

        io.replace("run_pe/CMakeLists.txt", "/MT", "", {plain = true})
        io.replace("libpeconv/CMakeLists.txt", "/MT", "", {plain = true})
        if package:is_plat("windows") then
            os.mkdir(path.join(package:buildir(), "run_pe/pdb"))
            os.mkdir(path.join(package:buildir(), "libpeconv/pdb"))
        end
        import("package.tools.cmake").install(package, configs)
        os.trycp(path.join(package:buildir(), "run_pe/pdb/run_pe.pdb"), package:installdir("bin"))
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
