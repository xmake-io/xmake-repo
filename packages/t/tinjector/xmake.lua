package("tinjector")
    set_homepage("https://github.com/Mrack/TInjector")
    set_description("Hijacking Zygote to inject .so files before the app launches.")
    set_license("GPL-3.0")

    add_urls("https://github.com/Mrack/TInjector.git")

    add_versions("2024.09.23", "658f2c6478b13d74b615debf9480ffd70a7286e8")

    add_deps("elfio", "dobby")

    on_install("android", function (package)
        io.replace("jni/main.cpp", [[#include <sys/ptrace.h>]], [[#include <sys/ptrace.h>
#include <sys/system_properties.h>]], {plain = true})
        io.replace("jni/core/utils.cpp", [[#include "elfio/elfio.hpp"]], [[#include "elfio/elfio.hpp"
#include <sys/system_properties.h>]], {plain = true})
        os.cd("jni")
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")

            add_requires("elfio", "dobby")

            target("tinjector")
                set_languages("c++17")
                set_kind("binary")
                add_files("main.cpp")
                add_syslinks("dl", "log")

            target("tcore")
                set_languages("c++20")
                set_kind("$(kind)")
                add_files("core/*.cpp")
                add_headerfiles("core/(*.h)", "core/(*.hpp)")
                add_packages("dobby", "elfio")
                add_syslinks("log")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                hide_soinfo("libtarget.so");
                print_soinfos();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "hide.h"}))
    end)
