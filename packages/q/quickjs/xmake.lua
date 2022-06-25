package("quickjs")

    set_homepage("https://bellard.org/quickjs/")
    set_description("QuickJS is a small and embeddable Javascript engine")

    add_urls("https://github.com/bellard/quickjs.git")
    add_versions("2021.03.27", "b5e62895c619d4ffc75c9d822c8d85f1ece77e5b")

    if is_plat("linux", "macosx", "iphoneos", "cross") then
        add_syslinks("pthread", "dl", "m")
    elseif is_plat("android") then
        add_syslinks("dl", "m")
    elseif is_plat("windows") then
        add_deps("premake5")
        add_syslinks("ws2_32")
        -- add_syslinks("libucrt")
        add_patches("2021.03.27", path.join(os.scriptdir(), "patches", "2021.03.27", "fix_msvc.patch"), "17377b926d4d9c95566c17cc1d02c388b3113f2a318dfe4f4e806b313cda07c5")
    end
    
    on_install("linux", "macosx", "iphoneos", "android", "mingw", "cross", function (package)
        io.writefile("xmake.lua", ([[
            add_rules("mode.debug", "mode.release")
            target("quickjs")
                set_kind("$(kind)")
                add_files("quickjs*.c", "cutils.c", "lib*.c")
                add_headerfiles("quickjs-libc.h")
                add_headerfiles("quickjs.h")
                add_installfiles("*.js", {prefixdir = "share"})
                set_languages("c99")
                add_defines("CONFIG_VERSION=\"%s\"", "_GNU_SOURCE")
                add_defines("CONFIG_BIGNUM")
                if is_plat("windows", "mingw") then
                    add_defines("__USE_MINGW_ANSI_STDIO")
                end
        ]]):format(package:version_str()))
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        if package:is_plat("cross") then
            io.replace("quickjs.c", "#define CONFIG_PRINTF_RNDN", "")
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_install("windows", function (package)
        local vs = import("core.tool.toolchain").load("msvc"):config("vs")
        local msvc_version
        if tonumber(vs) == 2019 then
            msvc_version = "vs2019"
        elseif tonumber(vs) == 2022 then
            msvc_version = "vs2022"
        else
            raise("unsupported msvc version " .. msvc_version)
        end
        local kind = package:config("shared") and "SharedLib" or "StaticLib"
        local arch = package:is_arch("x86") and "x86_64" or "x64"
        -- premake5.lua
        io.writefile("premake5.lua", ([[
            function GenerateCArray(srcFile, dstFile, arrayName, arraySizeName)
                local src = io.readfile(srcFile)
                if src == nil then return false end
            
                if arrayName == nil then
                    arrayName = path.getbasename(dstFile)
                end
            
                if arraySizeName == nil then
                    arraySizeName = arrayName .. "_size"
                end
            
                local dst = "const unsigned char " .. arrayName .. "[] = {\n"
                local line = ""
            
                for i = 1, #src do
                    local byte = src:byte(i, i)
                    line = line .. string.format("0x%%02x, ", byte)
            
                    if (#line >= 80) or (i == #src) then
                        if i == #src then line = line:sub(1, #line - 2) end
            
                        dst = dst .. "\t" .. line .. "\n"
                        line = ""
                    end
                end
            
                dst = dst .. "};\n\n"
                dst = dst .. string.format("const unsigned " .. arraySizeName .. " = %%d;\n\n", #src)
            
                local oldDst = ""
                if os.isfile(dstFile) then oldDst = io.readfile(dstFile) end
            
                if oldDst ~= dst then
                    io.writefile(dstFile, dst)
                end
            
                return true
            end
            
            -----------------------------------------------------------------------------------------------------------------------
            
            workspace "quickjs"
                -- Premake output folder
                location(path.join(".build", _ACTION))
            
                -- Target architecture
                architecture "%s"
            
                -- Configuration settings
                configurations { "Debug", "Release" }
            
                -- Debug configuration
                filter { "configurations:Debug" }
                    defines { "DEBUG" }
                    symbols "On"
                    optimize "Off"
            
                -- Release configuration
                filter { "configurations:Release" }
                    defines { "NDEBUG" }
                    optimize "Speed"
                    inlining "Auto"
            
                filter { "language:not C#" }
                    defines { "_CRT_SECURE_NO_WARNINGS" }
                    characterset ("MBCS")
                    buildoptions { "/std:c++latest" }
            
                    if _ACTION == "vs2017" then
                        systemversion("10.0.17763.0")
                    end
            
                filter { }
                    targetdir "bin/%%{cfg.longname}/"
                    defines { "WIN32", "_AMD64_", "__x86_64__" }
                    exceptionhandling "Off"
                    rtti "Off"
                    vectorextensions "AVX2"
            
            -----------------------------------------------------------------------------------------------------------------------
            
            project "quickjs"
                language "C"
                kind "%s"
                files {
                    "cutils.c",
                    "cutils.h",
                    "libregexp.c",
                    "libregexp.h",
                    "libregexp-opcode.h",
                    "libunicode.c",
                    "libunicode.h",
                    "libunicode-table.h",
                    "list.h",
                    "quickjs.c",
                    "quickjs.h",
                    "quickjs-atom.h",
                    "quickjs-libc.c",
                    "quickjs-libc.h",
                    "quickjs-opcode.h"
                }
            
        ]]):format(arch, kind))
        -- premake generate sln 
        os.exec("premake5 " .. msvc_version)
        local configuration = package:debug() and "Debug" or "Release"
        -- msvc compile and build
        local configs = {".build/" .. msvc_version .. "/quickjs.sln"}
        table.insert(configs, "/p:platform=" .. os.arch())
        table.insert(configs, "/p:configuration=" .. configuration)
        import("package.tools.msbuild").build(package, configs)
        os.mv("quickjs.h", package:installdir("include"))
        os.trymv("bin/" .. configuration .. "/*.lib", package:installdir("lib"))
        os.trymv("bin/" .. configuration .. "/*.dll", package:installdir("lib"))
        if not package:config("shared") then 
            os.tryrm(package:installdir("bin/*.dll"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("JS_NewRuntime", {includes = "quickjs.h"}))
    end)