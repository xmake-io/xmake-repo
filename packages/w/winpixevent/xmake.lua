package("winpixevent")
    set_homepage("https://devblogs.microsoft.com/pix")
    set_description("WinPixEventRuntime + decoder + tests")
    set_license("MIT")

    add_urls("https://github.com/microsoft/PixEvents.git")
    add_versions("2024.03.19", "3a7e70dde7bf54f02f9d2e9dd6d3350c6cfb962f")

    add_includedirs("include", "include/WinPixEventRuntime")

    on_install("windows|!x86", function(package)
        import("package.tools.msbuild")
        if package:has_runtime("MT", "MTd") then
            if package:is_debug() then
                io.replace("decoder/lib/PixEventDecoder.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/dll/desktop/WinPixEventRuntime.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/lib/WinPixEventRuntime.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>\n</ClCompile>", {plain = true})
            else
                io.replace("decoder/lib/PixEventDecoder.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/dll/desktop/WinPixEventRuntime.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/lib/WinPixEventRuntime.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>\n</ClCompile>", {plain = true})
            end
        else
            if package:is_debug() then
                io.replace("decoder/lib/PixEventDecoder.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/dll/desktop/WinPixEventRuntime.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/lib/WinPixEventRuntime.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>\n</ClCompile>", {plain = true})
            else
                io.replace("decoder/lib/PixEventDecoder.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/dll/desktop/WinPixEventRuntime.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>\n</ClCompile>", {plain = true})
                io.replace("runtime/lib/WinPixEventRuntime.lib.vcxproj", "</ClCompile>", "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>\n</ClCompile>", {plain = true})
            end
        end
        os.cp("decoder/include", package:installdir())
        os.cp("include/*.h", path.join(package:installdir("include", "WinPixEventRuntime")))
        local configs = {}
        local arch = package:is_arch("x64") and "x64" or "x86"
        if package:is_arch("arm64") then
            arch = "ARM64"
        end
        local mode = package:is_debug() and "Debug" or "Release"
        table.insert(configs, "/p:Configuration=" .. mode)
        table.insert(configs, "/p:Platform=" .. arch)
        table.insert(configs, "runtime/lib/WinPixEventRuntime.lib.vcxproj")
        msbuild.build(package, configs)
        if package:config("shared") then
            -- Store only Configuration & Platform
            configs = {table.unpack(configs, 1, 2)}
            table.insert(configs, "runtime/dll/desktop/WinPixEventRuntime.vcxproj")
            -- Workaround for source\pixevents\runtime\lib\IncludePixEtw.h(21,10): error C1083: Cannot open include file: 'PIXETW.h': No such file or directory
            -- https://github.com/microsoft/PixEvents/blob/3a7e70dde7bf54f02f9d2e9dd6d3350c6cfb962f/runtime/lib/WinPixEventRuntime.lib.vcxproj#L33
            -- Copy from static build generated files out of .man file into root
            os.cp("runtime/lib/intermediates/MSG00001.bin", "MSG00001.bin")
            os.cp("runtime/lib/intermediates/PixEtw.h", "PixEtw.h")
            os.cp("runtime/lib/intermediates/PixEtw.rc", "PixEtw.rc")
            os.cp("runtime/lib/intermediates/PixEtwTEMP.BIN", "PixEtwTEMP.BIN")
            msbuild.build(package, configs)
        end
        if package:config("shared") then
            os.cp("runtime/dll/desktop/output/*/*/WinPixEventRuntime/WinPixEventRuntime.dll", package:installdir("bin"))
            os.cp("runtime/dll/desktop/output/*/*/WinPixEventRuntime/WinPixEventRuntime.lib", package:installdir("lib"))
        else
            os.cp("runtime/lib/output/*/*/WinPixEventRuntime.lib/WinPixEventRuntime.lib", package:installdir("lib"))
        end
        -- Store only Configuration & Platform
        configs = {table.unpack(configs, 1, 2)}
        table.insert(configs, "decoder/lib/PixEventDecoder.lib.vcxproj")
        msbuild.build(package, configs)
        os.cp("decoder/lib/output/*/*/PixEventDecoder.lib/PixEventDecoder.lib.lib", path.join(package:installdir("lib"), "PixEventDecoder.lib"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("PIXEndCapture", {configs = {languages = "c++17"}, includes = {"windows.h", "pix3.h"}}))
        assert(package:check_cxxsnippets({test = [[
            using PixEventsLegacy::PIXEventsGraphicsRecordSpaceQwords;
            void test() {
                UINT64 buffer[PIXEventsGraphicsRecordSpaceQwords];
                PixEventsLegacy::EncodeBeginEventForContext(buffer, 0u, "hello %s %d %f", "world", 1, 1.0f);
                auto nameAndColor = PixEventDecoder::TryDecodePIXBeginEventOrPIXSetMarkerBlob(buffer, &buffer[PIXEventsGraphicsRecordSpaceQwords - 1]);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"windows.h", "PIXEventsLegacy.h", "PixEventDecoder.h"}}))
    end)
