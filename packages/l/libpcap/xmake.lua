package("libpcap")

    set_homepage("https://www.tcpdump.org/")
    set_description("the LIBpcap interface to various kernel packet capture mechanism")
    set_license("BSD-3-Clause")

    add_urls("https://www.tcpdump.org/release/libpcap-$(version).tar.gz", {alias = "home"})
    add_urls("https://github.com/the-tcpdump-group/libpcap.git", {alias = "github"})
    add_versions("home:1.10.5", "37ced90a19a302a7f32e458224a00c365c117905c2cd35ac544b6880a81488f0")
    add_versions("home:1.10.4", "ed19a0383fad72e3ad435fd239d7cd80d64916b87269550159d20e47160ebe5f")
    add_versions("home:1.10.3", "2a8885c403516cf7b0933ed4b14d6caa30e02052489ebd414dc75ac52e7559e6")
    add_versions("home:1.10.2", "db6d79d4ad03b8b15fb16c42447d093ad3520c0ec0ae3d331104dcfb1ce77560")
    add_versions("home:1.10.1", "ed285f4accaf05344f90975757b3dbfe772ba41d1c401c2648b7fa45b711bdd4")

    add_versions("github:libpcap-1.10.5", "6cd9835338ca334b699b1217e2aee2b873463c76aafd19b8b9d4710554f025ac")
    add_versions("github:libpcap-1.10.4", "1783ff39f2a6eb99a7625c7ea471782614c94965ea934b6b22ac6eb38db266bc")
    add_versions("github:libpcap-1.10.3", "a16162a829d527ec0d233c294ffa3d4db199a5ae2f9ee5be2e3ae9bb4083ab30")
    add_versions("github:libpcap-1.10.2", "fb2a9392bd3967b6bf46ce22163bdf69102cedb5c0174ff8f7909bfacaa435c5")
    add_versions("github:libpcap-1.10.1", "7b650c9e0ce246aa41ba5463fe8e903efc444c914a3ccb986547350bed077ed6")
    
    add_configs("remote", {description = "Enable remote capture support (requires openssl)", default = true, type = "boolean"})
    
    add_deps("cmake", "flex", "bison")

    on_load(function (package)
        if package:config("remote") then
            package:add("deps", "openssl")
        end
    end)

    on_install("linux", "macosx", "android", "bsd", function (package)
        local configs = {
            "-DDISABLE_AIRPCAP=ON",
            "-DDISABLE_DPDK=ON",
            "-DDISABLE_NETMAP=ON",
            "-DDISABLE_BLUETOOTH=ON",
            "-DDISABLE_DBUS=ON",
            "-DDISABLE_RDMA=ON",
            "-DDISABLE_DAG=ON",
            "-DDISABLE_SEPTEL=ON",
            "-DDISABLE_SNF=ON",
            "-DDISABLE_TC=ON",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        if package:is_plat("macosx") and package:is_arch("arm64") then
            table.insert(configs, "-DCMAKE_OSX_ARCHITECTURES=arm64")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_STATIC_RT=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_REMOTE=" .. (package:config("remote") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:config("shared") then
            os.rm(path.join(package:installdir("lib"), "lib*.a"))
        else
            os.rm(path.join(package:installdir("lib"), "lib*.so"))
            os.rm(path.join(package:installdir("lib"), "lib*.dylib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pcap_create", {includes = "pcap.h"}))
    end)
