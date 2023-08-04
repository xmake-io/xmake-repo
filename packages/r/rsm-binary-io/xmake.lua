package("rsm-binary-io")
    set_homepage("https://github.com/Ryan-rsm-McKenzie/binary_io")
    set_description("A binary i/o library for C++, without the agonizing pain")
    set_license("MIT")

    add_urls("https://github.com/Ryan-rsm-McKenzie/binary_io/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Ryan-rsm-McKenzie/binary_io.git")
    add_versions("2.0.6", "88354a25064f3da58bdcb24049ca23d7d8f4fb3e12496f397937a65d1943f114")
    add_versions("2.0.5", "4cc904ef02f77e04756cbdf01372629b0f04d859f06ee088d854468abdd4b840")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++20")
            target("rsm-binary-io")
                set_kind("static")
                add_files("src/**.cpp")
                add_includedirs("include/")
                add_headerfiles("include/(**.hpp)")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int main() {
                binary_io::span_istream s;
                assert(s.tell() == 0);
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"binary_io/binary_io.hpp", "assert.h"}}))
    end)
