package("libsdl_gfx")
    add_deps("libsdl")
    on_load(function(package)
        package:add("includedirs", "include")
    end)

    set_homepage("https://www.ferzkopp.net/wordpress/2016/01/02/sdl_gfx-sdl2_gfx/")
    set_description("Simple DirectMedia Layer primitives drawing library")

    if is_plat("windows") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).zip")
        add_versions("1.0.4", "b6da07583b7fb8f4d8cee97cac9176b97a287f56a8112e22f38183ecf47b9dcb")
    elseif is_plat("macosx", "linux") then
        set_urls("https://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$(version).tar.gz")
        add_versions("1.0.4", "63e0e01addedc9df2f85b93a248f06e8a04affa014a835c2ea34bfe34e576262")
    end

    add_links("SDL2_gfx")

    on_install("windows", function(package)
        local file_name = "SDL2_gfx.vcxproj"
        local inf = io.open(file_name, 'r')
        local lines = ""
        local line_count = 1
        while(true) do
            local line = inf:read("*line")
            if not line then break end
            lines = lines .. line .. "\n"
            if line_count == 11 then
                lines = lines .. "<ProjectConfiguration Include=\"Debug|x64\"><Configuration>Debug</Configuration><Platform>x64</Platform></ProjectConfiguration>\n"
                lines = lines .. "<ProjectConfiguration Include=\"Release|x64\"><Configuration>Release</Configuration><Platform>x64</Platform></ProjectConfiguration>\n"
            elseif line_count == 30 then
                lines = lines .. "<PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='Release|x64'\" Label=\"Configuration\"><ConfigurationType>DynamicLibrary</ConfigurationType><CharacterSet>Unicode</CharacterSet><WholeProgramOptimization>true</WholeProgramOptimization><PlatformToolset>v141</PlatformToolset></PropertyGroup>\n"
                lines = lines .. "<PropertyGroup Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\" Label=\"Configuration\"><ConfigurationType>DynamicLibrary</ConfigurationType><CharacterSet>Unicode</CharacterSet><PlatformToolset>v141</PlatformToolset></PropertyGroup>\n"
            elseif line_count == 39 then
                lines = lines .. "<ImportGroup Condition=\"'$(Configuration)|$(Platform)'=='Release|x64'\" Label=\"PropertySheets\"><Import Project=\"$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\" Condition=\"exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')\" Label=\"LocalAppDataPlatform\" /></ImportGroup>\n"
                lines = lines .. "<ImportGroup Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\" Label=\"PropertySheets\"><Import Project=\"$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props\" Condition=\"exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')\" Label=\"LocalAppDataPlatform\" /></ImportGroup>\n"
            elseif line_count == 48 then
                lines = lines .. "<OutDir Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\">$(Platform)\\$(Configuration)\\</OutDir><IntDir Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\">$(Platform)\\$(Configuration)\\</IntDir><LinkIncremental Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\">true</LinkIncremental>\n"
                lines = lines .. "<OutDir Condition=\"'$(Configuration)|$(Platform)'=='Release|x64'\">$(Platform)\\$(Configuration)\\</OutDir><IntDir Condition=\"'$(Configuration)|$(Platform)'=='Release|x64'\">$(Platform)\\$(Configuration)\\</IntDir><LinkIncremental Condition=\"'$(Configuration)|$(Platform)'=='Release|x64'\">false</LinkIncremental>\n"
            elseif line_count == 106 then
                lines = lines .. "<ItemDefinitionGroup Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\"><ClCompile><Optimization>Disabled</Optimization><AdditionalIncludeDirectories>..\\SDL2-2.0.5\\include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories><PreprocessorDefinitions>WIN32;_DEBUG;_WINDOWS;_USRDLL;DLL_EXPORT;USE_MMX;%(PreprocessorDefinitions)</PreprocessorDefinitions><MinimalRebuild>true</MinimalRebuild><BasicRuntimeChecks>EnableFastChecks</BasicRuntimeChecks><RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary><PrecompiledHeader></PrecompiledHeader><WarningLevel>Level3</WarningLevel><DebugInformationFormat>EditAndContinue</DebugInformationFormat></ClCompile><Link><AdditionalDependencies>SDL2.lib;%(AdditionalDependencies)</AdditionalDependencies><AdditionalLibraryDirectories>..\\SDL2-2.0.5\\VisualC\\$(Platform)\\$(Configuration);%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories><GenerateDebugInformation>true</GenerateDebugInformation><SubSystem>Windows</SubSystem><RandomizedBaseAddress>false</RandomizedBaseAddress><DataExecutionPrevention></DataExecutionPrevention><ImportLibrary></ImportLibrary><TargetMachine>MachineX64</TargetMachine></Link><PostBuildEvent><Command></Command></PostBuildEvent></ItemDefinitionGroup>\n"
                lines = lines .. "<ItemDefinitionGroup Condition=\"'$(Configuration)|$(Platform)'=='Release|x64'\"><ClCompile><Optimization>MaxSpeed</Optimization><AdditionalIncludeDirectories>..\\SDL2-2.0.5\\include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories><IntrinsicFunctions>true</IntrinsicFunctions><PreprocessorDefinitions>WIN32;_DEBUG;_WINDOWS;_USRDLL;DLL_EXPORT;%(PreprocessorDefinitions)</PreprocessorDefinitions><RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary><FunctionLevelLinking>true</FunctionLevelLinking><PrecompiledHeader></PrecompiledHeader><WarningLevel>Level3</WarningLevel><DebugInformationFormat>ProgramDatabase</DebugInformationFormat></ClCompile><Link><AdditionalDependencies>SDL2.lib;%(AdditionalDependencies)</AdditionalDependencies><AdditionalLibraryDirectories>..\\SDL2-2.0.5\\VisualC\\$(Platform)\\$(Configuration);%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories><GenerateDebugInformation>true</GenerateDebugInformation><SubSystem>Windows</SubSystem><OptimizeReferences>true</OptimizeReferences><EnableCOMDATFolding>true</EnableCOMDATFolding><TargetMachine>MachineX64</TargetMachine></Link><PostBuildEvent><Command></Command></PostBuildEvent></ItemDefinitionGroup>\n"
            elseif line_count == 123 then
                lines = lines .. "<ExcludedFromBuild Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\">true</ExcludedFromBuild>\n"
            elseif line_count == 127 then
                lines = lines .. "<ExcludedFromBuild Condition=\"'$(Configuration)|$(Platform)'=='Debug|x64'\">true</ExcludedFromBuild>\n"
            end
            line_count = line_count + 1
        end
        inf:close()
        io.writefile(file_name, lines)

        local file_name = "SDL2_gfx.vcxproj"
        local content = io.readfile(file_name)

        content = content:gsub("<WindowsTargetPlatformVersion>10.0.14393.0</WindowsTargetPlatformVersion>", "")
        content = content:gsub("v141", "v142")
        content = content:gsub("%%%(AdditionalIncludeDirectories%)", package:dep("libsdl"):installdir("include", "SDL2") .. ";%%%(AdditionalIncludeDirectories%)")
        content = content:gsub("%%%(AdditionalLibraryDirectories%)", package:dep("libsdl"):installdir("lib") .. ";%%%(AdditionalLibraryDirectories%)")

        io.writefile(file_name, content)

        local file_name = "SDL2_gfx.sln"
        local inf = io.open(file_name, 'r')
        local lines = ""
        local line_count = 1
        while(true) do
            local line = inf:read("*line")
            if not line then break end
            lines = lines .. line .. "\n"
            if line_count == 17 then
                lines = lines .. "Debug|x64 = Debug|x64\n"
                lines = lines .. "Release|x64 = Release|x64\n"
            elseif line_count == 21 then
                lines = lines .. "\t\t{AE22EFD3-6E6D-48C0-AF3D-EF190406BEDC}.Debug|x64.ActiveCfg = Debug|x64\n\t\t{AE22EFD3-6E6D-48C0-AF3D-EF190406BEDC}.Debug|x64.Build.0 = Debug|x64\n"
            elseif line_count == 23 then
                lines = lines .. "\t\t{AE22EFD3-6E6D-48C0-AF3D-EF190406BEDC}.Release|x64.ActiveCfg = Release|x64\n\t\t{AE22EFD3-6E6D-48C0-AF3D-EF190406BEDC}.Release|x64.Build.0 = Release|x64\n"
            end
            line_count = line_count + 1
        end
        inf:close()
        io.writefile(file_name, lines)

        local configs = {}
        local build_dir = ""

        if package:arch() == "x86" then
            build_dir = "Win32"
        else
            build_dir = "x64"
        end

        table.insert(configs, "/property:Configuration=Release")
        table.insert(configs, "/property:Platform=" .. build_dir)
        table.insert(configs, "-target:SDL2_gfx")

        import("package.tools.msbuild").build(package, configs)

        build_dir = path.join(build_dir, "Release")

        os.cp(path.join(build_dir, "*.lib"), package:installdir("lib"))
        os.cp(path.join(build_dir, "*.dll"), package:installdir("lib"))
        os.cp("*.h", package:installdir("include", "SDL2"))

        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_framerate.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)

        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_gfxPrimitives.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)

        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_rotozoom.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end

        table.insert(configs, "--with-sdl-prefix=" .. package:dep("libsdl"):installdir())

        import("package.tools.autoconf").install(package, configs)
        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_framerate.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)

        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_gfxPrimitives.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)

        local file_name = path.join(package:installdir("include"), "SDL2", "SDL2_rotozoom.h")
        local content = io.readfile(file_name)

        content = content:gsub("\"SDL.h\"", "<SDL2/SDL.h>")

        io.writefile(file_name, content)
    end)
