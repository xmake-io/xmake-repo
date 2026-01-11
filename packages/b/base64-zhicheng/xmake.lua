package("base64-zhicheng")
    set_homepage("https://github.com/zhicheng/base64")
    set_description("base64 c implementation")
    set_license("Public Domain")

    add_urls("https://github.com/zhicheng/base64.git")
    add_versions("2019.09.08", "81060e3338120b43d759ee8adfe24619370c5f36")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("base64")
                set_kind("$(kind)")
                add_files("base64.c")
                add_headerfiles("(*.h)")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <base64.h>
            #include <stdlib.h>
            void test() {
                unsigned char *encode = "foobar";
                unsigned int encodelen = 6;
                char *encode_out = malloc(BASE64_ENCODE_OUT_SIZE(encodelen));
                base64_encode(encode, encodelen, encode_out);
            }
        ]]}, {configs = {languages = "c99"}}))
    end)
