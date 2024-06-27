package("npcap_sdk")
    set_homepage("https://npcap.com/")
    set_description("Npcap is the Nmap Project's packet capture (and sending) library for Microsoft Windows.")

    set_urls("https://npcap.com/dist/npcap-sdk-$(version).zip")
    add_versions("1.13", "dad1f2bf1b02b787be08ca4862f99e39a876c1f274bac4ac0cedc9bbc58f94fd")

    on_install("windows", function (package)
        os.cp("Include", package:installdir())
        if package:is_arch("arm64") then
            os.cp("Lib/ARM64/*", package:installdir("lib"))
        elseif package:is_arch("x86") then
            os.cp("Lib/*.lib", package:installdir("lib"))
        else
            os.cp("Lib/x64/*.lib", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PacketGetVersion", {includes = "Packet32.h"}))
    end)
