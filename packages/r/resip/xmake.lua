package("resip")
    set_homepage("https://resiprocate.org/Main_Page")
    set_description("C++ implementation of SIP, ICE, TURN and related protocols.")

    add_urls("https://github.com/resiprocate/resiprocate/archive/refs/tags/resiprocate-$(version).tar.gz")
    add_versions("1.12.0", "aa8906082e4221bffbfab3210df68a6ba1f57ba1532d89ea4572b4fa9877914f")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
        add_syslinks("ws2_32", "advapi32")
    else
        add_links("resip", "dum", "rutil", "resipares")
        add_deps("autotools")
        add_deps("openssl", "c-ares")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end
    if is_plat("macosx", "iphoneos", "bsd") then
        add_deps("pkg-config")
    end

    on_check("android", function (package)
        if package:is_plat("android") and is_subhost("windows") then
            raise("package(resip) does not support android@windows.")
        end
    end)

    on_load("windows", function(package)
        package:add("defines", "WIN32")
    end)

    on_install("windows", function(package)
        import("package.tools.msbuild")
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
            io.replace("reSIProcate_15_0.sln", "|x64", "|ARM64", {plain = true})
        end
        local mode = package:is_debug() and "Debug" or "Release"
        local configs = { "reSIProcate_15_0.sln" }
        table.insert(configs, "/t:resiprocate;dum;rutil")
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        for _, vcxproj in ipairs(os.files("**.vcxproj")) do
            if package:is_arch("arm64") then
                io.replace(vcxproj, "|x64", "|ARM64", {plain = true})
                io.replace(vcxproj, "<Platform>x64", "<Platform>ARM64", {plain = true})
            end
            if package:has_runtime("MT", "MTd") then
                -- Allow MT, MTd
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>", {plain = true})
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>", {plain = true})
            end
            -- Allow use another Win SDK
            io.replace(vcxproj, "<WindowsTargetPlatformVersion>10.0.17134.0</WindowsTargetPlatformVersion>", "", {plain = true})
        end
        -- std::binary_function requires #include <functional>
        io.replace("rutil/dns/RRCache.hxx", "#include <memory>", "#include <memory>\n#include <functional>", {plain = true})
        msbuild.build(package, configs)
        os.cp("rutil/**.hxx", package:installdir("include/rutil"), {rootdir = "rutil"})
        os.cp("rutil/**.h", package:installdir("include/rutil"), {rootdir = "rutil"})
        os.cp("resip/**.hxx", package:installdir("include/resip"), {rootdir = "resip"})
        os.cp("resip/**.h", package:installdir("include/resip"), {rootdir = "resip"})
        os.cp("*/*/resiprocate.lib", package:installdir("lib"))
        os.cp("*/*/dum.lib", package:installdir("lib"))
        os.cp("*/*/ares.lib", package:installdir("lib"))
        os.cp("*/*/rutil.lib", package:installdir("lib"))
    end)

    on_install("!windows and !wasm and !mingw", function(package)
        local opt = {}
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("bsd", "android") then
            opt.cxflags = "-D_LIBCPP_ENABLE_CXX17_REMOVED_AUTO_PTR"
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <rutil/Socket.hxx>
            #include <rutil/Data.hxx>
            #include <rutil/TransportType.hxx>
            #include <resip/stack/Tuple.hxx>
            void test() {
                resip::Tuple v4tuple(resip::Data::Empty,2000,resip::IpVersion::V4,resip::TransportType::UDP,resip::Data::Empty);
                auto p = v4tuple.getPort();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
