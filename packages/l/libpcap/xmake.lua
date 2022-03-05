package("libpcap")

    set_homepage("https://www.tcpdump.org/")
    set_description("the LIBpcap interface to various kernel packet capture mechanism")
    set_license("BSD-3-Clause")

    add_urls("https://www.tcpdump.org/release/libpcap-$(version).tar.gz")
    add_urls("https://github.com/the-tcpdump-group/libpcap.git")
    add_versions("1.10.1", "ed285f4accaf05344f90975757b3dbfe772ba41d1c401c2648b7fa45b711bdd4")

    add_deps("cmake", "flex", "bison")

    on_install("linux", "macosx", "android", function (package)
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
            "-DENABLE_REMOTE=OFF",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_STATIC_RT=" .. (package:config("shared") and "OFF" or "ON"))
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
