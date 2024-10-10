package("pcapplusplus")
    set_homepage("https://github.com/seladb/PcapPlusPlus")
    set_description("PcapPlusPlus is a multiplatform C++ library for capturing, parsing and crafting of network packets.")
    set_license("Unlicense")

    set_urls("https://github.com/seladb/PcapPlusPlus/archive/refs/tags/$(version).zip",
             "https://github.com/seladb/PcapPlusPlus.git")

    add_versions("v24.09", "0a9d80d09a906c08a1df5f5a937134355c7cb3fc8a599bf1a0f10002cf0285be")
    add_versions("v23.09", "f2b92d817df6138363be0d144a61716f8ecc43216f0008135da2e0e15727d35a")

    add_patches("v24.09", "patches/v24.09/vla.patch", "8c380468c78118b6d85f6b3856cd49c4d890fd326dde3400b8c47c01c885cef4")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_links("Pcap++", "Packet++", "Common++")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "iphlpapi")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "SystemConfiguration")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    if is_plat("windows", "mingw") then
        add_deps("npcap_sdk")
    elseif is_plat("linux", "macosx", "android", "bsd") then
        add_deps("libpcap")
    end

    on_install("windows", "mingw", "linux", "macosx", "android", "bsd", function (package)
        local configs = {
            "-DPCAPPP_BUILD_EXAMPLES=OFF",
            "-DPCAPPP_BUILD_TESTS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include "pcapplusplus/IPv4Layer.h"
            #include "pcapplusplus/Packet.h"
            #include "pcapplusplus/PcapFileDevice.h"
            #include "pcapplusplus/PcapLiveDeviceList.h"

            void testPcapFileReaderDevice() {
                pcpp::PcapFileReaderDevice reader("1_packet.pcap");
            }

            void testPcapLiveDeviceList() {
                std::vector<pcpp::PcapLiveDevice *> devList = 
                    pcpp::PcapLiveDeviceList::getInstance().getPcapLiveDevicesList();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
