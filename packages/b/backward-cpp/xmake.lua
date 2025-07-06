package("backward-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bombela/backward-cpp")
    set_description("Backward is a beautiful stack trace pretty printer for C++.")
    set_license("MIT")

    add_urls("https://github.com/bombela/backward-cpp/archive/refs/tags/$(version).zip",
             "https://github.com/bombela/backward-cpp.git")

    add_versions("v1.6", "9b07e12656ab9af8779a84e06865233b9e30fadbb063bf94dd81d318081db8c2")

    add_configs("stack_walking", {description = "Choose stack walking library to use.", default = nil, type = "string", values = {"unwind", "libunwind", "backtrace"}})
    add_configs("stack_details", {description = "Choose stack details library to use.", default = nil, type = "string", values = {"dw", "bfd", "dwarf", "backtrace_symbol"}})

    if is_plat("mingw") then
        add_patches("v1.6", "patches/v1.6/link_to_imagehlp.patch", "0a135b6d68970ff6609a3eb4deb2b10c317eee15ba980eb178b93402a97c957c")

        if is_arch("i386") then
            add_patches("v1.6", "patches/v1.6/fix_32bit_ssize_t_typedef.patch", "fb372fe5934984aecb00b3153f737f63a542ff9359d159a9bcb79c5d54963b42")
        end
    end

    if is_plat("windows", "mingw") then
        add_syslinks("psapi", "dbghelp")
    elseif is_plat("linux", "bsd", "android") then
        add_syslinks("dl", "m")
    end

    add_deps("cmake")

    on_load(function (package)
        local stack_walking = package:config("stack_walking")
        if stack_walking == "libunwind" then
            package:add("deps", "libunwind")
        end

        local stack_details = package:config("stack_details")
        if stack_details == "dwarf" then
            package:add("deps", "libdwarf", "libelf")
        elseif stack_details == "dw" then
            package:add("deps", "elfutils")
        elseif stack_details == "bfd" then
            package:add("deps", "binutils")
            package:add("syslinks", "bfd")
        end

        package:add("defines", "BACKWARD_HAS_UNWIND=" .. (stack_walking == "unwind" and "1" or "0"))
        package:add("defines", "BACKWARD_HAS_LIBUNWIND=" .. (stack_walking == "libunwind" and "1" or "0"))
        package:add("defines", "BACKWARD_HAS_BACKTRACE=" .. (stack_walking == "backtrace" and "1" or "0"))

        package:add("defines", "BACKWARD_HAS_BACKTRACE_SYMBOL=" .. (stack_details == "backtrace_symbol" and "1" or "0"))
        package:add("defines", "BACKWARD_HAS_DW=" .. (stack_details == "dw" and "1" or "0"))
        package:add("defines", "BACKWARD_HAS_BFD=" .. (stack_details == "bfd" and "1" or "0"))
        package:add("defines", "BACKWARD_HAS_DWARF=" .. (stack_details == "dwarf" and "1" or "0"))
        package:add("defines", "BACKWARD_HAS_PDB_SYMBOL=" .. (is_plat("windows") and "1" or "0"))
    end)

    on_install("(!windows or windows|!arm64) and !android and !bsd and !wasm and !cross", function (package)
        local configs = {"-DBACKWARD_TESTS=OFF", "-DSTACK_DETAILS_AUTO_DETECT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBACKWARD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end

        local stack_walking = package:config("stack_walking")
        local stack_details = package:config("stack_details")

        table.insert(configs, "-DSTACK_WALKING_UNWIND=" .. ((stack_walking == "unwind") and "ON" or "OFF"))
        table.insert(configs, "-DSTACK_WALKING_LIBUNWIND=" .. ((stack_walking == "libunwind") and "ON" or "OFF"))
        table.insert(configs, "-DSTACK_WALKING_BACKTRACE=" .. ((stack_walking == "backtrace") and "ON" or "OFF"))
        table.insert(configs, "-DSTACK_DETAILS_BACKTRACE_SYMBOL=" .. ((stack_walking == "backtrace_symbol") and "ON" or "OFF"))
        table.insert(configs, "-DSTACK_DETAILS_DW=" .. ((stack_walking == "dw") and "ON" or "OFF"))
        table.insert(configs, "-DSTACK_DETAILS_BFD=" .. ((stack_walking == "bfd") and "ON" or "OFF"))
        table.insert(configs, "-DSTACK_DETAILS_DWARF=" .. ((stack_walking == "dwarf") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        io.replace("backward.hpp", [[#pragma comment(lib, "psapi.lib")]], "", {plain = true})
        io.replace("backward.hpp", [[#pragma comment(lib, "dbghelp.lib")]], "", {plain = true})

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
