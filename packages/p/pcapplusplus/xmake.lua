package("pcapplusplus")
    set_homepage("https://github.com/seladb/PcapPlusPlus")
    set_description("PcapPlusPlus is a multiplatform C++ library for capturing, parsing and crafting of network packets.")

    set_urls("https://github.com/seladb/PcapPlusPlus/archive/refs/tags/$(version).zip",
             "https://github.com/seladb/PcapPlusPlus.git")

    add_versions("v23.09", "f2b92d817df6138363be0d144a61716f8ecc43216f0008135da2e0e15727d35a")

    add_deps("cmake", "npcap_sdk")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "IPv4Layer.h"
            #include "Packet.h"
            #include "PcapFileDevice.h"
            void test() {
                pcpp::PcapFileReaderDevice reader("1_packet.pcap");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
