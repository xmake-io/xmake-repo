package("libgpiod")
    set_homepage("https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/about/")
    set_description("libgpiod - C library and tools for interacting with the linux GPIO character device (gpiod stands for GPIO device)")

    add_urls("https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-$(version).tar.gz",
             "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git")
    add_versions("v2.0.1", "cf0d4db1d94cc99281de142063d0e28f42760c4d918d6b8854e1b27811517c34")
    add_versions("v2.0", "a0f835c4ca4a2a3ca021090b574235ba58bb9fd612d8a6051fb1350054e04fdd")
    add_versions("v1.6.4", "9f920260c46b155f65cba8796dcf159e4ba56950b85742af357d75a1af709e68")

    on_install("linux", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        
        local configure = io.readfile("configure.ac")
        local version = configure:match("AC_INIT%(%[libgpiod%], %[(.+)%]%)")
        print("version: " .. version)
        package:add("defines", "GPIOD_VERSION_STR=" .. version)

        import("package.tools.xmake").install(package)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.runv("gpiodetect")
        assert(package:check_cxxsnippets({test = [[
            #include <gpiod.hpp>
            #include <gpiod.h>
            void test() {
                gpiod_api_version();
                gpiod::api_version;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
