package("aklomp-base64")
    set_homepage("https://github.com/aklomp/base64")
    set_description("Fast Base64 stream encoder/decoder in C99, with SIMD acceleration.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/aklomp/base64.git")

    add_versions("0.5.2", "8bdda2d47caf8b066999c5bd01069e55bcd0d396")

    add_deps("cmake")
    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "BASE64_STATIC_DEFINE")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE="  .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                char src[] = "hello world";
                char out[20];
                size_t srclen = sizeof(src) - 1;
                size_t outlen;

                base64_encode(src, srclen, out, &outlen, 0);
            }
        ]]}, {configs = {languages = "c99"}, includes = "libbase64.h"}))
    end)
