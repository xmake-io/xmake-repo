package("backward-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bombela/backward-cpp")
    set_description("Backward is a beautiful stack trace pretty printer for C++.")
    set_license("MIT")

    add_urls("https://github.com/bombela/backward-cpp/archive/refs/tags/$(version).zip",
             "https://github.com/bombela/backward-cpp.git")

    add_versions("v1.6", "9b07e12656ab9af8779a84e06865233b9e30fadbb063bf94dd81d318081db8c2")

    add_configs("bfd", {description = "Get stack trace with details about your sources by using libbfd from binutils.", default = false, type = "boolean"})

    if is_plat("mingw") then
        add_patches("v1.6", "patches/v1.6/link_to_imagehlp.patch", "0a135b6d68970ff6609a3eb4deb2b10c317eee15ba980eb178b93402a97c957c")

        if is_arch("i386") then
            add_patches("v1.6", "patches/v1.6/fix_32bit_ssize_t_typedef.patch", "fb372fe5934984aecb00b3153f737f63a542ff9359d159a9bcb79c5d54963b42")
        end
    end

    if is_plat("windows", "mingw") then
        add_syslinks("psapi", "dbghelp")
    elseif is_plat("linux", "bsd") then
        add_syslinks("dl", "m")
    end

    add_deps("cmake")

    on_load("linux", "mingw@msys", "macos", function (package)
        if package:config("bfd") then
            package:add("deps", "binutils")
            package:add("syslinks", "bfd")
            package:add("defines", "BACKWARD_HAS_BFD=1")
        end
    end)

    on_install(function (package)
        io.replace("backward.hpp", [[#pragma comment(lib, "psapi.lib")]], "", {plain = true})
        io.replace("backward.hpp", [[#pragma comment(lib, "dbghelp.lib")]], "", {plain = true})

        local configs = {"-DBACKWARD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        import("package.tools.cmake").install(package, configs)
        os.cp(package:installdir("include/*.hpp"), package:installdir("include/backward"))
        os.cp(package:installdir("include/*.hpp"), package:installdir("lib/backward"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                backward::Printer printer;
                backward::StackTrace st;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "backward.hpp"}))
    end)
