package("tao_idl")
    set_kind("binary")
    set_homepage("https://www.dre.vanderbilt.edu/~schmidt/TAO.html")
    set_description("tao_idl is TAO's Interface Description Language (IDL) compiler, based on Sun Microsystems' OMG IDL Compiler Front End (CFE) version 1.3, implements most IDL v3 & some IDL v4 features.")
    set_license("DocumentRef-COPYING:LicenseRef-DOC-License")

    add_urls("https://github.com/DOCGroup/ACE_TAO/releases/download/$(version).tar.gz", {version = function (version) 
        return "ACE%2BTAO-" .. version:gsub("%.", "_")  .. "/ACE%2BTAO-" .. version
    end})

    add_versions("8.0.3", "b9130369be615f75042504d1e22ae6bcba20f0068de31787182f46381ec85340")

    add_deps("ace", {configs = {shared = true}})

    on_load(function (package)
        package:addenv("PATH", "bin")
    end)

    on_install("windows", function(package)
        import("package.tools.msbuild")
        local include_paths = {"..", "include", "be_include", "fe"}
        local lib_paths = {"../../lib"}
        -- Fetch *ace* dependency
        local packagedep = package:dep("ace")
        if packagedep then
            local fetchinfo = packagedep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(include_paths, includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(lib_paths, linkdir)
                end
            end
        end
        os.cd("TAO/TAO_IDL")
        -- Prepare .vcxproj using config & de-bundle ace dependency
        for _, vcxproj in ipairs({
            "../../apps/gperf/src/gperf_vs2022.vcxproj",
            "TAO_IDL_FE_vs2022.vcxproj",
            "TAO_IDL_BE_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_A_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_C_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_E_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_I_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_O_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_S_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_U_vs2022.vcxproj",
            "TAO_IDL_BE_VIS_V_vs2022.vcxproj",
            "TAO_IDL_EXE_vs2022.vcxproj"
        }) do
            io.replace(vcxproj,
                "<AdditionalIncludeDirectories>.-</AdditionalIncludeDirectories>",
                "<AdditionalIncludeDirectories>" .. table.concat(include_paths, ";") .. "</AdditionalIncludeDirectories>", {plain = false})
            io.replace(vcxproj,
                "<AdditionalLibraryDirectories>.-</AdditionalLibraryDirectories>",
                "<AdditionalLibraryDirectories>" .. table.concat(lib_paths, ";") .. "</AdditionalLibraryDirectories>", {plain = false})
            if package:has_runtime("MT", "MTd") then
                -- Allow MT, MTd
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>", {plain = true})
                io.replace(vcxproj, "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>", {plain = true})
            end
            -- Allow use another Win SDK
            io.replace(vcxproj, "<WindowsTargetPlatformVersion>10.0</WindowsTargetPlatformVersion>", "", {plain = true})
            -- Disable LTCG
            io.replace(vcxproj, "<WholeProgramOptimization>true</WholeProgramOptimization>", "", {plain = true})
        end
        -- Build & install .exe
        for _, target in ipairs({"../../apps/gperf/src/gperf_vs2022.vcxproj", "TAO_IDL_vs2022.sln"}) do
            local configs = { target }
            if target:match("TAO_IDL_vs2022.sln") then
                table.insert(configs, "/t:TAO_IDL_FE;TAO_IDL_BE;TAO_IDL_BE_VIS_A;TAO_IDL_BE_VIS_C;TAO_IDL_BE_VIS_E;TAO_IDL_BE_VIS_I;TAO_IDL_BE_VIS_O;TAO_IDL_BE_VIS_S;TAO_IDL_BE_VIS_U;TAO_IDL_BE_VIS_V;TAO_IDL_EXE")
            end
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
        end
        os.cd("../..")
        os.cp("**.exe", package:installdir("bin"))
        os.cp("**.lib", package:installdir("lib"))
        os.trycp("**.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("tao_idl -h")
    end)
