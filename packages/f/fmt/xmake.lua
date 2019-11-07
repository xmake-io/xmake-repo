package("fmt")

    set_homepage("https://fmt.dev")
    set_description("fmt is an open-source formatting library for C++. It can be used as a safe and fast alternative to (s)printf and iostreams.")

    set_urls("https://github.com/fmtlib/fmt/releases/download/$(version)/fmt-$(version).zip")
    add_versions("6.0.0", "b4a16b38fa171f15dbfb958b02da9bbef2c482debadf64ac81ec61b5ac422440")
    add_versions("5.3.0", "4c0741e10183f75d7d6f730b8708a99b329b2f942dad5a9da3385ab92bb4a15c")

    add_deps("cmake")

    add_configs("header_only", {description = "Use header only", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("header_only") then
            package:add("defines", "FMT_HEADER_ONLY=1")
        end
        if package:config("shared") then
            package:add("defines", "FMT_EXPORT")
        end
    end)
    
    on_install("windows", function (package)
        if package:config("header_only") then
            os.cp("include/fmt", package:installdir("include"))
            return
        end
        
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package)
    end)
    
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fmt/format.h>
            #include <string>
            #include <assert.h>
            static void test() {
                std::string s = fmt::format("{}", "hello");
                assert(s == "hello");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "fmt/format.h", defines="FMT_HEADER_ONLY"}))
    end)    
    
