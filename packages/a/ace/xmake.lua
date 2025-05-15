package("ace")
    set_homepage("https://www.dre.vanderbilt.edu/~schmidt/ACE.html")
    set_description("ACE (ADAPTIVE Communication Environment) is a C++ framework for implementing distributed and networked applications.")

    add_urls("https://github.com/DOCGroup/ACE_TAO/releases/download/$(version).tar.gz", {version = function (version) 
        return "ACE%2BTAO-" .. version:gsub("%.", "_")  .. "/ACE-" .. version
    end})

    add_versions("8.0.3", "d8fcd1f5fab609ab11ed86abdbd61e6d00d5305830fa6e57c17ce395af5e86dc")

    on_load("windows", function (package)
        package:add("syslinks", "advapi32")
        package:add("defines", "WIN32")
        if not package:config("shared") then
            package:add("defines", "ACE_AS_STATIC_LIBS")
        end
    end)

    on_install("windows", function(package)
        import("package.tools.msbuild")
        io.writefile("ace/config.h", [[#include "ace/config-win32.h"]])
        os.cp("ace/**.h", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.inl", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.cpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.tpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.ipp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cp("ace/**.hpp", package:installdir("include/ace"), {rootdir = "ace"})
        os.cd("ace")
        for _, vcxproj in ipairs({"ACE_vs2022.vcxproj",
                "Compression/ACE_Compression_vs2022.vcxproj",
                "Compression/rle/ACE_RLECompression_vs2022.vcxproj",
                "ETCL/ACE_ETCL_vs2022.vcxproj",
                "ETCL/ACE_ETCL_Parser_vs2022.vcxproj",
                "QoS/QoS_vs2022.vcxproj",
                "Monitor_Control/Monitor_Control_vs2022.vcxproj"}) do
            if package:has_runtime("MT", "MTd") then
                -- Allow MT, MTd
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>", {plain = true})
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>", {plain = true})
            end
            if not package:config("shared") then
                io.replace(vcxproj, "DynamicLibrary", "StaticLibrary", {plain = true})
                io.replace(vcxproj, "ACE_BUILD_DLL", "ACE_AS_STATIC_LIBS", {plain = true})
                io.replace(vcxproj, "ACE_[%w_]+_BUILD_DLL", "ACE_AS_STATIC_LIBS", {plain = false})
                io.replace(vcxproj, "[%w_]+_[%w_]+_BUILD_DLL", "ACE_AS_STATIC_LIBS", {plain = false})
            end
            -- Allow use another Win SDK
            io.replace(vcxproj, "<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>", "", {plain = true})
            -- Disable LTCG
            io.replace(vcxproj, "<WholeProgramOptimization>true</WholeProgramOptimization>", "", {plain = true})
        end
        local configs = { "ACE_vs2022.sln" }
        local arch = package:is_arch("x64") and "x64" or "Win32"
        if package:is_arch("arm64") then
            arch = "ARM64"
        end
        local mode = package:is_debug() and "Debug" or "Release"
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        -- Wrap vstool so it would build for another vstools
        local msvc = import("core.tool.toolchain").load("msvc")
        local vs = msvc:config("vs")
        local vstool
        if     vs == "2015" then vstool = "v140"
        elseif vs == "2017" then vstool = "v141"
        elseif vs == "2019" then vstool = "v142"
        elseif vs == "2022" then vstool = "v143"
        end
        table.insert(configs, "/p:PlatformToolset=" .. vstool)
        msbuild.build(package, configs)
        os.cd("..")
        os.cp("**.lib", package:installdir("lib"))
        if package:config("shared") then
            os.cp("**.dll", package:installdir("bin"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
                #define WIN32_LEAN_AND_MEAN
                #include <windows.h>
                #include <ace/ACE.h>
                void test() {
                    auto c_name = ACE::compiler_name();
                }
            ]]
        }, {configs = {languages = "c++17"}}))
    end)
