package("xerces-c")

    set_homepage("https://xerces.apache.org/xerces-c/")
    set_description("Xerces-C++ is a validating XML parser written in a portable subset of C++.")
    set_license("Apache-2.0")

    add_urls("https://archive.apache.org/dist/xerces/c/3/sources/xerces-c-$(version).zip")
    add_versions("3.2.5", "4aa0f7ed265a45d253f900fa145cc8cae10414d085695f1de03a2ec141a3358b")
    add_versions("3.2.4", "563a668b331ca5d1fc08ed52e5f62a13508b47557f88a068ad1db6f68e1f2eb2")

    add_configs("xmlch_type", {description = "XMLCh type (UTF-16 character type)", default = "char16_t", type = "string", values = {"char16_t", "uint16_t", "wchar_t"}})
    add_configs("mutex_manager", {description = "Thread support", default = "standard", type = "string", values = {"standard", "posix", "windows", "nothreads"}})
    local is_system_transcoder_supported = is_plat("linux", "windows", "mingw", "macosx")
    add_configs("transcoder", {description = "Transcoder (used to convert between internal UTF-16 and other encodings)", default = is_system_transcoder_supported and "system_transcoder" or "iconv", type = "string", values = {"system_transcoder", "iconv", "icu"}})
    add_configs("message_loader", {description = "Message Loader (used to access diagnostics messages)", default = "inmemory", type = "string", values = {"inmemory", "icu", "iconv"}})
    add_configs("network_accessor", {description = "Net Accessor (used to access network resources)", default = "off", type = "string", values = {"off", "curl", "sockets", "cfurl", "winsock"}})

    add_deps("cmake")
    if is_plat("android") then
        -- for NDK version less than 26
        add_patches(">=3.2.4",
            path.join(os.scriptdir(), "patches", "patch-android.diff"),
            "f58fa2c89e1d4a17d5af193df3e3e5918986b71beb6ce055e9edd1546c20318a")
    end

    on_check("android|armeabi-v7a", function (package)
        import("core.tool.toolchain")
        local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
        local ndk_sdkver = ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) >= 26, "package(xerces-c): need ndk api level >= 26 for android armeabi-v7a")
    end)

    on_check(function (package)
        if package:config("xmlch_type") == "wchar_t" then
            assert(package:is_plat("windows"), "Windows only")
        end
        if package:config("mutex_manager") == "windows" then
            assert(package:is_plat("windows"), "Windows only")
        elseif package:config("mutex_manager") == "posix" then
            assert((not package:is_plat("windows")) or package:is_plat("cygwin"), "UNIX and Cygwin only")
        end
    end)

    on_load(function (package)
        if package:config("transcoder") == "system_transcoder" then
            if package:is_plat("linux") then
                package:add("deps", "libiconv", {system = true})
            elseif package:is_plat("windows", "mingw") then
                package:add("syslinks", "advapi32")
            elseif package:is_plat("macosx") then
                package:add("frameworks", "CoreFoundation", "CoreServices")
            else
                raise("`system_transcoder` only support GNU iconv library, macOS APIs and Windows APIs!")
            end
        elseif package:config("transcoder") == "iconv" then
            package:add("deps", "libiconv", {system = false})
        elseif package:config("transcoder") == "icu" then
            package:add("deps", "icu4c")
        end

        if package:config("message_loader") == "iconv" then
            package:add("deps", "libiconv")
        elseif package:config("message_loader") == "icu" then
            package:add("deps", "icu4c")
        end

        if package:config("network_accessor") == "curl" then
            assert(not package:is_plat("windows"), "UNIX only")
            package:add("deps", "libcurl")
        elseif package:config("network_accessor") == "sockets" then
            assert(not package:is_plat("windows"), "UNIX only")
        elseif package:config("network_accessor") == "cfurl" then
            assert(package:is_plat("macosx"), "macOS only")
            package:add("frameworks", "CoreServices")
        elseif package:config("network_accessor") == "winsock" then
            assert(package:is_plat("windows", "cygwin", "mingw"), "Windows, Cygwin, MingGW only")
            package:add("syslinks", "advapi32")
        end
    end)

    on_install("windows", "macosx", "linux", "android", function (package)
        local configs = {
            "-Dxmlch-type=" .. package:config("xmlch_type"),
            "-Dmutex-manager=" .. package:config("mutex_manager"),
            "-Dmessage-loader=" .. package:config("message_loader")
        }
        if package:config("mutex_manager") == "nothreads" then
            table.insert(configs, "-Dthreads:BOOL=OFF")
        end

        if package:config("transcoder") == "system_transcoder" then
            if package:is_plat("linux") then
                table.insert(configs, "-Dtranscoder=gnuiconv")
            elseif package:is_plat("windows", "mingw") then
                table.insert(configs, "-Dtranscoder=windows")
            elseif package:is_plat("macosx") then
                table.insert(configs, "-Dtranscoder=macosunicodeconverter")
            end
        elseif package:config("transcoder") == "iconv" then
            table.insert(configs, "-Dtranscoder=iconv")
        elseif package:config("transcoder") == "icu" then
            table.insert(configs, "-Dtranscoder=icu")
        end

        if package:config("network_accessor") == "off" then
            table.insert(configs, "-Dnetwork:BOOL=OFF")
        else
            table.insert(configs, "-Dnetwork-accessor=" .. package:config("network_accessor"))
        end

        local packagedeps = {}
        if package:config("transcoder") == "iconv" or package:config("message_loader") == "iconv" then
            table.insert(packagedeps, "libiconv")
        end
        if package:config("transcoder") == "icu" or package:config("message_loader") == "icu" then
            table.insert(packagedeps, "icu4c")
            io.replace(
                "cmake/FindICU.cmake",
                "add_library(${_ICU_imported_target} UNKNOWN IMPORTED)",
                [[
                    add_library(${_ICU_imported_target} UNKNOWN IMPORTED)
                    target_compile_features(${_ICU_imported_target} INTERFACE cxx_std_17)
                ]],
                {plain = true})
        end
        if package:config("network_accessor") == "curl" then
            table.insert(packagedeps, "libcurl")
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace xercesc;
            void test() {
                try {
                    XMLPlatformUtils::Initialize();
                }
                catch (const XMLException& toCatch) {
                    return;
                }
                XMLPlatformUtils::Terminate();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "xercesc/util/PlatformUtils.hpp"}))
    end)
