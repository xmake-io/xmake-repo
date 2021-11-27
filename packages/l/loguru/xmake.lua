package("loguru")

    set_homepage("https://github.com/emilk/loguru")
    set_description("A lightweight C++ logging library")

    add_urls("https://github.com/emilk/loguru/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emilk/loguru.git")
    add_versions("v2.1.0", "1a3be62ebec5609af60b1e094109a93b7412198b896bb88f31dcfe4d95b79ce7")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("fmt", {description = "Use fmt to format the log.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    elseif is_plat("bsd") then
        add_syslinks("pthread", "dl", "execinfo")
    end
    on_load(function (package)
        if package:config("fmt") then
            package:add("deps", "fmt")
            package:add("defines", "LOGURU_USE_FMTLIB")
        end
    end)

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("cxx11")
            option("with_fmt", {default = false, showmenu = true})
            if has_config("with_fmt") then
                add_requires("fmt")
            end
            target("loguru")
                set_kind("static")
                add_files("loguru.cpp")
                add_headerfiles("loguru.hpp")
                if is_plat("cross") then
                    add_defines("LOGURU_STACKTRACES=0")
                end
                if has_config("with_fmt") then
                    add_packages("fmt")
                    add_defines("LOGURU_USE_FMTLIB")
                end
        ]])
        import("package.tools.xmake").install(package, {with_fmt = package:config("fmt")})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <loguru.hpp>
            void test(int argc, char* argv[]) {
                loguru::init(argc, argv);
                LOG_F(INFO, "Hello from main.cpp!");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
