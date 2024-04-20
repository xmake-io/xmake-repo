package("abseil")

    set_homepage("https://abseil.io")
    set_description("C++ Common Libraries")
    set_license("Apache-2.0")

    add_urls("https://github.com/abseil/abseil-cpp/archive/$(version).tar.gz",
             "https://github.com/abseil/abseil-cpp.git")
    add_versions("20200225.1", "0db0d26f43ba6806a8a3338da3e646bb581f0ca5359b3a201d8fb8e4752fd5f8")
    add_versions("20210324.1", "441db7c09a0565376ecacf0085b2d4c2bbedde6115d7773551bc116212c2a8d6")
    add_versions("20210324.2", "59b862f50e710277f8ede96f083a5bb8d7c9595376146838b9580be90374ee1f")
    add_versions("20211102.0", "dcf71b9cba8dc0ca9940c4b316a0c796be8fab42b070bb6b7cab62b48f0e66c4")
    add_versions("20220623.0", "4208129b49006089ba1d6710845a45e31c59b0ab6bff9e5788a87f55c5abd602")
    add_versions("20230125.2", "9a2b5752d7bfade0bdeee2701de17c9480620f8b237e1964c1b9967c75374906")
    add_versions("20230802.1", "987ce98f02eefbaf930d6e38ab16aa05737234d7afbab2d5c4ea7adbe50c28ed")
    add_versions("20240116.1", "3c743204df78366ad2eaf236d6631d83f6bc928d1705dd0000b872e53b73dc6a")

    add_deps("cmake")

    add_configs("cxx_standard", {description = "Select c++ standard to build.", default = "17", type = "string", values = {"14", "17", "20"}})

    if is_plat("macosx") then
        add_frameworks("CoreFoundation")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ABSL_CONSUME_DLL")
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", "cross", function (package)
        if package:version() and package:version():eq("20230802.1") and package:is_plat("mingw") then
            io.replace(path.join("absl", "synchronization", "internal", "pthread_waiter.h"), "#ifndef _WIN32", "#if !defined(_WIN32) && !defined(__MINGW32__)", {plain = true})
            io.replace(path.join("absl", "synchronization", "internal", "win32_waiter.h"), "#if defined(_WIN32) && _WIN32_WINNT >= _WIN32_WINNT_VISTA", "#if defined(_WIN32) && !defined(__MINGW32__) && _WIN32_WINNT >= _WIN32_WINNT_VISTA", {plain = true})
        end
        local configs = {"-DCMAKE_CXX_STANDARD=" .. package:config("cxx_standard"), "-DABSL_ENABLE_INSTALL=ON", "-DABSL_PROPAGATE_CXX_STD=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})

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
        ]]}, {configs = {languages = "cxx17"}}))
    end)
