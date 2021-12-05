package("libtins")

    set_homepage("http://libtins.github.io/")
    set_description("High-level, multiplatform C++ network packet sniffing and crafting library.")

    set_urls("https://github.com/mfontanini/libtins/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mfontanini/libtins.git")
    add_versions("v4.2", "a9fed73e13f06b06a4857d342bb30815fa8c359d00bd69547e567eecbbb4c3a1")

    add_deps("cmake", "boost")

    on_install("linux", "windows", "macosx", function (package)
        local configs = {"-DLIBTINS_BUILD_EXAMPLES=OFF", "-DLIBTINS_BUILD_TESTS=OFF",
            "-DLIBTINS_ENABLE_PCAP=OFF",
            "-DLIBTINS_ENABLE_DOT11=OFF",
            "-DLIBTINS_ENABLE_WPA2=OFF",
            "-DLIBTINS_ENABLE_TCPIP=OFF",
            "-DLIBTINS_ENABLE_ACK_TRACKER=OFF",
            "-DLIBTINS_ENABLE_TCP_STREAM_CUSTOM_DATA=OFF",
            "-DLIBTINS_ENABLE_WPA2_CALLBACKS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBTINS_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace Tins;
            void test() {
                SnifferConfiguration config;
                config.set_promisc_mode(true);
                config.set_filter("udp and port 53");
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"tins/tins.h"}}))
    end)
