package("winpcap")
    set_homepage("https://www.winpcap.org/")
    set_description("The industry-standard windows packet capture library")

    set_urls("https://www.winpcap.org/install/bin/WpdPack_$(version).zip", 
             {version = function (version) return version:gsub("%.", "_") end})

    add_versions("4.1.2", "ea799cf2f26e4afb1892938070fd2b1ca37ce5cf75fec4349247df12b784edbd")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_defines("WIN32")

    on_install("windows|x86", "windows|x64", function (package)
        os.cp("Include/*", package:installdir("include"))
        if package:is_arch("x86") or package:is_arch("i386") then
            os.cp("Lib/*.lib", package:installdir("lib"))
        else
            os.cp("Lib/x64/*.lib", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pcap_findalldevs", {includes = "pcap.h"}))
    end)
