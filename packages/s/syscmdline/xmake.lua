package("syscmdline")
    set_homepage("https://github.com/SineStriker/syscmdline")
    set_description("C++ Advanced Command Line Parser")
    set_license("MIT")

    add_urls("https://github.com/SineStriker/syscmdline.git")

    add_versions("2024.03.27", "70e18ba18056bff1bebab924dde73dbbf04d46f9")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("shell32")
    end

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "SYSCMDLINE_STATIC")
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSYSCMDLINE_BUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            namespace SCL = SysCmdLine;
            void test() {
                SCL::Command cmd("mv", "move files to directory");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "syscmdline/parser.h"}))
    end)
