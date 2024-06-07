package("libtins")

    set_homepage("http://libtins.github.io/")
    set_description("High-level, multiplatform C++ network packet sniffing and crafting library.")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/mfontanini/libtins/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mfontanini/libtins.git")
    add_versions("v4.5", "6ff5fe1ada10daef8538743dccb9c9b3e19d05d028ffdc24838e62ff3fc55841")
    add_versions("v4.4", "ff0121b4ec070407e29720c801b7e1a972042300d37560a62c57abadc9635634")

    add_deps("cmake", "boost")
    if is_plat("windows") then
        add_syslinks("ws2_32", "iphlpapi")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "TINS_STATIC")
        end
    end)

    on_install("linux", "windows", "macosx", function (package)
        local configs = {
            "-DCMAKE_INSTALL_LIBDIR=lib",
            "-DLIBTINS_BUILD_EXAMPLES=OFF",
            "-DLIBTINS_BUILD_TESTS=OFF",
            "-DLIBTINS_ENABLE_PCAP=OFF",
            "-DLIBTINS_ENABLE_DOT11=OFF",
            "-DLIBTINS_ENABLE_WPA2=OFF",
            "-DLIBTINS_ENABLE_TCPIP=OFF",
            "-DLIBTINS_ENABLE_ACK_TRACKER=OFF",
            "-DLIBTINS_ENABLE_TCP_STREAM_CUSTOM_DATA=OFF",
            "-DLIBTINS_ENABLE_WPA2_CALLBACKS=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBTINS_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <string>
            using namespace Tins;
            void test() {
                std::string name = NetworkInterface::default_interface().name();
                printf("%s\n", name.c_str());
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"tins/tins.h"}}))
    end)
