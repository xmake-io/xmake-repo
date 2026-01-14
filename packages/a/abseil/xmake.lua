package("abseil")
    set_homepage("https://abseil.io")
    set_description("C++ Common Libraries")
    set_license("Apache-2.0")

    add_urls("https://github.com/abseil/abseil-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/abseil/abseil-cpp.git")

    add_versions("20260107.0", "4c124408da902be896a2f368042729655709db5e3004ec99f57e3e14439bc1b2")
    add_versions("20250814.1", "1692f77d1739bacf3f94337188b78583cf09bab7e420d2dc6c5605a4f86785a1")
    add_versions("20250814.0", "9b2b72d4e8367c0b843fa2bcfa2b08debbe3cee34f7aaa27de55a6cbb3e843db")
    add_versions("20250512.1", "9b7a064305e9fd94d124ffa6cc358592eb42b5da588fb4e07d09254aa40086db")
    add_versions("20250512.0", "7262daa7c1711406248c10f41026d685e88223bc92817d16fb93c19adb57f669")
    add_versions("20250127.1", "b396401fd29e2e679cace77867481d388c807671dc2acc602a0259eeb79b7811")
    add_versions("20200225.1", "0db0d26f43ba6806a8a3338da3e646bb581f0ca5359b3a201d8fb8e4752fd5f8")
    add_versions("20210324.1", "441db7c09a0565376ecacf0085b2d4c2bbedde6115d7773551bc116212c2a8d6")
    add_versions("20210324.2", "59b862f50e710277f8ede96f083a5bb8d7c9595376146838b9580be90374ee1f")
    add_versions("20211102.0", "dcf71b9cba8dc0ca9940c4b316a0c796be8fab42b070bb6b7cab62b48f0e66c4")
    add_versions("20220623.0", "4208129b49006089ba1d6710845a45e31c59b0ab6bff9e5788a87f55c5abd602")
    add_versions("20230125.2", "9a2b5752d7bfade0bdeee2701de17c9480620f8b237e1964c1b9967c75374906")
    add_versions("20230802.1", "987ce98f02eefbaf930d6e38ab16aa05737234d7afbab2d5c4ea7adbe50c28ed")
    add_versions("20240116.1", "3c743204df78366ad2eaf236d6631d83f6bc928d1705dd0000b872e53b73dc6a")
    add_versions("20240116.2", "733726b8c3a6d39a4120d7e45ea8b41a434cdacde401cba500f14236c49b39dc")
    add_versions("20240722.0", "f50e5ac311a81382da7fa75b97310e4b9006474f9560ac46f54a9967f07d4ae3")
    add_versions("20250127.0", "16242f394245627e508ec6bb296b433c90f8d914f73b9c026fddb905e27276e8")

    add_patches("20240116.1", "https://github.com/abseil/abseil-cpp/commit/3335e58f198e899a500b744163f9b883035a5217.patch", "f83278086b42bc997846d2b931a266678f96e2727fce6ffd98b2b58ce75fa0a3")
    add_patches("20240116.2", "https://github.com/abseil/abseil-cpp/commit/3335e58f198e899a500b744163f9b883035a5217.patch", "f83278086b42bc997846d2b931a266678f96e2727fce6ffd98b2b58ce75fa0a3")

    add_deps("cmake")

    add_configs("cxx_standard", {description = "Select c++ standard to build.", default = "17", type = "string", values = {"14", "17", "20"}})

    on_load(function (package)
        if package:is_plat("windows", "mingw", "msys") then
            package:add("syslinks", "advapi32", "dbghelp", "bcrypt")
        elseif package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread")
        elseif package:is_plat("macosx", "iphoneos") then
            package:add("frameworks", "CoreFoundation")
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ABSL_CONSUME_DLL")
        end
    end)

    on_install(function (package)
        local version = package:version()
        if version and version:eq("20230802.1") and package:is_plat("mingw") then
            io.replace(path.join("absl", "synchronization", "internal", "pthread_waiter.h"), "#ifndef _WIN32", "#if !defined(_WIN32) && !defined(__MINGW32__)", {plain = true})
            io.replace(path.join("absl", "synchronization", "internal", "win32_waiter.h"), "#if defined(_WIN32) && _WIN32_WINNT >= _WIN32_WINNT_VISTA", "#if defined(_WIN32) && !defined(__MINGW32__) && _WIN32_WINNT >= _WIN32_WINNT_VISTA", {plain = true})
        end
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")]], "", {plain = true})
        if version and package:is_plat("macosx") then
            local file_path = path.join("absl", "time", "internal", "cctz", "src", "time_zone_format.cc")
            if version:ge("20240116.1") and version:le("20260107.0") then
                io.replace(
                    file_path,
                    "#if !defined(_XOPEN_SOURCE) && !defined(__FreeBSD__) && !defined(__OpenBSD__)", 
                    "#if !defined(_XOPEN_SOURCE) && !defined(__FreeBSD__) && !defined(__OpenBSD__) && !defined(__APPLE__)",
                    {plain = true}
                )
            elseif version:eq("20230802.1") then
                io.replace(
                    file_path,
                    "#if !defined(_XOPEN_SOURCE) && !defined(__OpenBSD__)", 
                    "#if !defined(_XOPEN_SOURCE) && !defined(__FreeBSD__) && !defined(__OpenBSD__) && !defined(__APPLE__)",
                    {plain = true}
                )
            end
        end

        local configs = {
            "-DCMAKE_CXX_STANDARD=" .. package:config("cxx_standard"),
            "-DABSL_ENABLE_INSTALL=ON",
            "-DABSL_PROPAGATE_CXX_STD=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {builddir = os.tmpfile() .. ".dir"})

        -- get links and ensure link order
        import("core.base.graph")
        local dag = graph.new(true)
        local pkgconfigdir = package:installdir("lib", "pkgconfig")
        for _, pcfile in ipairs(os.files(path.join(pkgconfigdir, "*.pc"))) do
            local link = path.basename(pcfile)
            local content = io.readfile(pcfile)
            for _, line in ipairs(content:split("\n")) do
                if line:startswith("Requires: ") then
                    local requires = line:sub(10):split(",")
                    for _, dep in ipairs(requires) do
                        dep = dep:split("=")[1]:trim()
                        dag:add_edge(link, dep)
                    end
                end
            end
        end
        local links = dag:topological_sort()
        package:add("links", links)

        local cycle = dag:find_cycle()
        if cycle then
            wprint("cycle links found", cycle)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "absl/strings/numbers.h"
            #include "absl/strings/str_join.h"
            #include <iostream>
            #include <string>
            #include <vector>
            void test() {
                std::vector<std::string> v = {"foo", "bar", "baz"};
                std::string s = absl::StrJoin(v, "-");
                int result = 0;
                auto a = absl::SimpleAtoi("123", &result);
                std::cout << "Joined string: " << s << "\\n";
            }
        ]]}, {configs = {languages = "cxx" .. package:config("cxx_standard")}}))
    end)
