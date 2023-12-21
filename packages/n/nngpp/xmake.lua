package("nngpp")

    set_homepage("https://github.com/cwzx/nngpp")
    set_description("C++ wrapper around the nanomsg NNG API.")

    add_urls("https://github.com/cwzx/nngpp.git")
    add_versions("v2020.10.30", "8da8c026bd551b7685a8a140909ff96cfe91bf90")

    add_deps("nng")
    add_deps("cmake")
    on_install("windows", "linux", "macosx", "android", "iphoneos", "cross", function (package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nngpp/nngpp.h>
            static void test() {
                nng::aio aio = nng::make_aio();
            }
        ]]}, {includes = "nngpp/nngpp.h",configs = {languages = "c++11"}}))
    end)
