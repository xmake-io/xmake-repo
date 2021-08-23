package("resip")

    set_homepage("https://resiprocate.org/Main_Page")
    set_description("C++ implementation of SIP, ICE, TURN and related protocols.")

    add_urls("https://www.resiprocate.org/files/pub/reSIProcate/releases/resiprocate-$(version).tar.gz")
    add_versions("1.12.0", "046826503d3c8682ae0e42101b28f903c5f988235f1ff4a98dbfb9066d0d3d49")
    add_versions("1.10.2", "b66dd1cb4b5e79e9bc7200ef260941283a2ff108b4982b841e49415892a702ef")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    if is_plat("linux") or is_plat("macosx") then
        add_links("dum", "resip", "rutil")
    end

    on_install("windows", function(package)
        import("package.tools.msbuild")
        local arch = package:is_arch("x64") and "x64" or "Win32"
        local mode = package:debug() and "Debug" or "Release"
        local configs = { "reSIProcate_15_0.sln" }
        table.insert(configs, "/t:resiprocate")
        table.insert(configs, "/t:dum")
        table.insert(configs, "/t:rutil")
        table.insert(configs, "/t:ares")
        table.insert(configs, "/property:Configuration=" .. mode)
        table.insert(configs, "/property:Platform=" .. arch)
        import("core.tool.toolchain")
        local msvc = toolchain.load("msvc")
        local windows_sdk_version = msvc:runenvs()["WindowsSDKVersion"]
        table.insert(configs, "/p:WindowsTargetPlatformVersion=" .. windows_sdk_version)
        print("Windows SDK Version: ", windows_sdk_version)
        msbuild.build(package, configs)
        os.vcp("rutil/*.hxx", package:installdir("include/rutil"))
        os.vcp("rutil/*.h", package:installdir("include/rutil"))
        os.vcp("rutil/dns/*.hxx", package:installdir("include/rutil/dns"))
        os.vcp("rutil/dns/ares/*.h", package:installdir("include/rutil/dns/ares"))
        os.vcp("rutil/ssl/*.hxx", package:installdir("include/rutil/ssl"))
        os.vcp("rutil/stun/*.hxx", package:installdir("include/rutil/stun"))
        os.vcp("rutil/wince/*.hxx", package:installdir("include/rutil/wince"))
        os.vcp("resip/dum/*.hxx", package:installdir("include/resip/dum"))
        os.vcp("resip/dum/ssl/*.hxx", package:installdir("include/resip/dum/ssl"))
        os.vcp("resip/stack/*.hxx", package:installdir("include/resip/stack"))
        os.vcp("resip/stack/ssl/*.hxx", package:installdir("include/resip/stack/ssl"))
        os.trycp(path.join(arch, mode, "ares.lib"), package:installdir("lib"))
        os.trycp(path.join(arch, mode, "dum.lib"), package:installdir("lib"))
        os.trycp(path.join(arch, mode, "rutil.lib"), package:installdir("lib"))
        os.trycp(path.join(arch, mode, "resiprocate.lib"), package:installdir("lib"))
        os.trycp(path.join(arch, mode, "ares.dll"), package:installdir("lib"))
        os.trycp(path.join(arch, mode, "dum.dll"), package:installdir("lib"))
        os.trycp(path.join(arch, mode, "rutil.dll"), package:installdir("lib"))
        os.trycp(path.join(arch, mode, "resiprocate.dll"), package:installdir("lib"))
    end)

    on_install("linux", "macosx", function(package)
        local confs = {}
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.autoconf").install(package, confs)
    end)

    on_test(function(package)
        assert({includes = "resip/stack/SipStack.hxx"})
    end)
