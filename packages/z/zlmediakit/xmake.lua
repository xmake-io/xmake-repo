package("zlmediakit")
    set_homepage("https://github.com/ZLMediaKit/ZLMediaKit")
    set_description("WebRTC/RTSP/RTMP/HTTP/HLS/HTTP-FLV/WebSocket-FLV/HTTP-TS/HTTP-fMP4/WebSocket-TS/WebSocket-fMP4/GB28181/SRT server and client framework based on C++11")
    set_license("MIT")

    add_urls("https://github.com/ZLMediaKit/ZLMediaKit.git",
             "https://gitee.com/xia-chu/ZLMediaKit.git", {submodules = false})
    add_versions("2023.11.3", "9f28384cd998f6ed6faf53b6d8ee3c9780c34bc5")         
    add_versions("2023.8.26", "895e93cb6aae82f9fd6f19b0980c28062b6b9d2f")
    
    add_configs("c_api", {description = "Enable C API SDK.", default = false, type = "boolean"})
    add_configs("c_static_api", {description = "Enable mk_api static lib.", default = false, type = "boolean"})

    add_configs("cxx_api", {description = "Enable C++ API SDK.", default = true, type = "boolean"})
    add_configs("server_lib", {description = "Enable server as android static library.", default = false, type = "boolean"})

    add_configs("asan", {description = "Enable Address Sanitize.", default = false, type = "boolean"})
    add_configs("mem_debug", {description = "Enable Memory Debug.", default = false, type = "boolean"})

    add_configs("webrtc", {description = "ENABLE WEBRTC.", default = false, type = "boolean"})
    add_configs("srt", {description = "ENABLE SRT.", default = false, type = "boolean"})
    add_configs("jemalloc", {description = "Enable static linking to the jemalloc library.", default = false, type = "boolean"})
    add_configs("ffmpeg", {description = "Enable FFMPEG.", default = false, type = "boolean"})
    add_configs("mysql", {description = "Enable MySQL.", default = false, type = "boolean"})
    add_configs("x264", {description = "Enable libx264.", default = false, type = "boolean"})
    add_configs("faac", {description = "Enable FAAC.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load("macosx", "linux", "windows", function(package) 
        if package:config("webrtc") or package:config("srt") then
            package:add("deps", "srtp", {configs = {openssl = true}})
            package:add("deps", "zltoolkit", {configs = {openssl = true}})
        else
            package:add("deps", "zltoolkit")
        end
    end)

    on_install("macosx", "linux", "windows", function (package)
        local configdeps = {
            c_api = "ENABLE_API",
            c_static_api = "ENABLE_API_STATIC_LIB",
            cxx_api = "ENABLE_CXX_API",
            server_lib = "ENABLE_SERVER_LIB",
            asan = "ENABLE_ASAN",
            mem_debug = "ENABLE_MEM_DEBUG",
            webrtc = "ENABLE_WEBRTC",
            srt = "ENABLE_SRT",
            jemalloc = "ENABLE_JEMALLOC_STATIC",
            ffmpeg = "ENABLE_FFMPEG",
            mysql = "ENABLE_MYSQL",
            x264 = "ENABLE_X264",
            faac = "ENABLE_FAAC"
        }
        local configs = {"-DENABLE_TESTS=OFF", "-DUSE_SOLUTION_FOLDERS=OFF", "-DENABLE_SERVER=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        for name, item in pairs(configdeps) do
            table.insert(configs, "-D" .. item .. "=" .. (package:config(name) and "ON" or "OFF"))
        end
        io.replace("CMakeLists.txt", "add_subdirectory(3rdpart)", "", {plain = true})
        io.replace("srt/CMakeLists.txt", "ZLMediaKit::ToolKit", "", {plain = true})
        io.replace("webrtc/CMakeLists.txt", "ZLMediaKit::ToolKit", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = {"zltoolkit"}})

        if package:config("shared") then
            if package:is_plat("windows") then
                os.trycp("**.dll", package:installdir("lib"))
                os.trycp("**.pdb", package:installdir("lib"))
            else
                os.trycp("**.so", package:installdir("lib"))
            end
        else
            if package:is_plat("windows") then
                os.trycp("**.lib", package:installdir("lib"))
            else
                os.trycp("**.a", package:installdir("lib"))
            end
        end

        os.cp("src/**.h", package:installdir("include"), {rootdir = "src"})
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
