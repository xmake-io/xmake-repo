package("zlmediakit")
    set_homepage("https://github.com/ZLMediaKit/ZLMediaKit")
    set_description("WebRTC/RTSP/RTMP/HTTP/HLS/HTTP-FLV/WebSocket-FLV/HTTP-TS/HTTP-fMP4/WebSocket-TS/WebSocket-fMP4/GB28181/SRT server and client framework based on C++11")
    set_license("MIT")

    add_urls("https://github.com/ZLMediaKit/ZLMediaKit.git",
            "https://gitee.com/xia-chu/ZLMediaKit.git")

    -- C-API
    add_configs("ENABLE_API", {description = "Enable C API SDK.", default = false, type = "boolean"})
    add_configs("ENABLE_API_STATIC_LIB", {description = "Enable mk_api static lib.", default = false, type = "boolean"})

    --C++ API
    add_configs("ENABLE_CXX_API", {description = "Enable C++ API SDK.", default = true, type = "boolean"})

    add_configs("ENABLE_SERVER", {description = "ENABLE SERVER.", default = false, type = "boolean"})
    add_configs("ENABLE_SERVER_LIB", {description = "Enable server as android static library.", default = false, type = "boolean"})

    --Recommended default
    add_configs("ENABLE_WEBRTC", {description = "ENABLE WEBRTC.", default = false, type = "boolean"})
    add_configs("ENABLE_SCTP", {description = "Enable SCTP.", default = true, type = "boolean"})
    add_configs("ENABLE_MP4", {description = "ENABLE_MP4.", default = true, type = "boolean"})
    add_configs("ENABLE_HLS", {description = "ENABLE_HLS.", default = true, type = "boolean"})
    add_configs("ENABLE_PLAYER", {description = "ENABLE PLAYER.", default = true, type = "boolean"})
    add_configs("ENABLE_RTPPROXY", {description = "ENABLE RTPPROXY.", default = true, type = "boolean"})
    

    add_configs("ENABLE_FAAC", {description = "Enable FAAC.", default = false, type = "boolean"})
    add_configs("ENABLE_ASAN", {description = "Enable Address Sanitize.", default = false, type = "boolean"})
    add_configs("ENABLE_MEM_DEBUG", {description = "Enable Memory Debug.", default = false, type = "boolean"})

    -- Dependencies
    add_configs("ENABLE_SRT", {description = "Enable SRT.", default = false, type = "boolean"})  -- Requires libsrtp-dev
    add_configs("ENABLE_OPENSSL", {description = "Enable OpenSSL.", default = false, type = "boolean"}) -- Requires openssl
    add_configs("ENABLE_JEMALLOC_STATIC", {description = "Enable static linking to the jemalloc library.", default = false, type = "boolean"})  -- Requires jemalloc
    add_configs("ENABLE_FFMPEG", {description = "Enable FFMPEG.", default = false, type = "boolean"})  -- Requires ffmpeg
    add_configs("ENABLE_MYSQL", {description = "Enable MySQL.", default = false, type = "boolean"})    -- Requires mysql
    add_configs("ENABLE_X264", {description = "Enable libx264.", default = false, type = "boolean"})   -- Requires libx264

    -- Typically no need to modify
    add_configs("ENABLE_WEPOLL", {description = "Enable WEPOLL.", default = true, type = "boolean"})
    add_configs("DISABLE_REPORT", {description = "Disable report to report.zlmediakit.com.", default = false, type = "boolean"})
    add_configs("ENABLE_TESTS", {description = "Enable TESTS.", default = false, type = "boolean"})
    add_configs("USE_SOLUTION_FOLDERS", {description = "Enable solution dir supported.", default = false, type = "boolean"})
    add_configs("ENABLE_MSVC_MT", {description = "Enable MSVC MT.", default = true, type = "boolean"})
    add_deps("cmake")
    --add_links("zlmediakit","zltoolkit","flv","mpeg","srt","jsoncpp","mov","ssl","crypto")     -- The SSL version might be too low, and specific linking order may be needed.

    on_install(function (package)
        local configs = {
            "-DENABLE_API=" .. (package:config("ENABLE_API") and "ON" or "OFF"),
            "-DENABLE_API_STATIC_LIB=" .. (package:config("ENABLE_API_STATIC_LIB") and "ON" or "OFF"),
            "-DENABLE_ASAN=" .. (package:config("ENABLE_ASAN") and "ON" or "OFF"),
            "-DENABLE_CXX_API=" .. (package:config("ENABLE_CXX_API") and "ON" or "OFF"),
            "-DENABLE_FAAC=" .. (package:config("ENABLE_FAAC") and "ON" or "OFF"),
            "-DENABLE_FFMPEG=" .. (package:config("ENABLE_FFMPEG") and "ON" or "OFF"),
            "-DENABLE_HLS=" .. (package:config("ENABLE_HLS") and "ON" or "OFF"),
            "-DENABLE_JEMALLOC_STATIC=" .. (package:config("ENABLE_JEMALLOC_STATIC") and "ON" or "OFF"),
            "-DENABLE_MEM_DEBUG=" .. (package:config("ENABLE_MEM_DEBUG") and "ON" or "OFF"),
            "-DENABLE_MSVC_MT=" .. (package:config("ENABLE_MSVC_MT") and "ON" or "OFF"),
            "-DENABLE_MYSQL=" .. (package:config("ENABLE_MYSQL") and "ON" or "OFF"),
            "-DENABLE_RTPPROXY=" .. (package:config("ENABLE_RTPPROXY") and "ON" or "OFF"),
            "-DENABLE_SERVER=" .. (package:config("ENABLE_SERVER") and "ON" or "OFF"),
            "-DENABLE_SRT=" .. (package:config("ENABLE_SRT") and "ON" or "OFF"),
            "-DENABLE_TESTS=" .. (package:config("ENABLE_TESTS") and "ON" or "OFF"),
            "-DENABLE_SCTP=" .. (package:config("ENABLE_SCTP") and "ON" or "OFF"),
            "-DENABLE_WEBRTC=" .. (package:config("ENABLE_WEBRTC") and "ON" or "OFF"),
            "-DENABLE_X264=" .. (package:config("ENABLE_X264") and "ON" or "OFF"),
            "-DENABLE_WEPOLL=" .. (package:config("ENABLE_WEPOLL") and "ON" or "OFF"),
            "-DDISABLE_REPORT=" .. (package:config("DISABLE_REPORT") and "ON" or "OFF"),
            "-DUSE_SOLUTION_FOLDERS=" .. (package:config("USE_SOLUTION_FOLDERS") and "ON" or "OFF")
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        
        print("========================================================")
        local ZLMediaKit_dir = package:installdir("include/ZLMediaKit/**");
        local ZLToolKit_dir = package:installdir("include/ZLToolKit/src/**");

        os.cp("**.a", package:installdir("lib"))
        os.cp("**.so", package:installdir("lib"))
        os.cp("**.dll", package:installdir("lib"))
        os.cp("**.pdb", package:installdir("lib"))
        os.cp("**.lib", package:installdir("lib"))

        for _, dir in ipairs(os.dirs(ZLMediaKit_dir)) do
            os.cp(dir,package:installdir("include"))
        end

        for _, dir in ipairs(os.dirs(ZLToolKit_dir)) do
            os.cp(dir,package:installdir("include"))
        end

        os.rm(package:installdir("include/ZLMediaKit"))
        os.rm(package:installdir("include/ZLToolKit"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
                void test() {
                    using namespace toolkit;
                    mINI ini;
                    ini[".dot"] = "dot-value";
                }
            ]]}, {configs = {languages = "c++11"}, includes = {"Common/config.h"}}))
        end)
package_end()