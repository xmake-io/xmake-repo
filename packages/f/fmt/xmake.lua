package("fmt")

    set_homepage("https://fmt.dev")
    set_description("fmt is an open-source formatting library for C++. It can be used as a safe and fast alternative to (s)printf and iostreams.")

    set_urls("https://github.com/fmtlib/fmt/releases/download/$(version)/fmt-$(version).zip")
    add_versions("6.2.0", "a4468d528682143dcef2f16068104e03ef50467b0170b6125c9caf777d27bf10")
    add_versions("6.0.0", "b4a16b38fa171f15dbfb958b02da9bbef2c482debadf64ac81ec61b5ac422440")
    add_versions("5.3.0", "4c0741e10183f75d7d6f730b8708a99b329b2f942dad5a9da3385ab92bb4a15c")

    add_configs("header_only", {description = "Use header only", default = true, type = "boolean"})
    add_configs("cmake",       {description = "Use cmake buildsystem", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("header_only") then
            package:add("defines", "FMT_HEADER_ONLY=1")
        end
        if not package:config("header_only") or package:config("cmake") then
            package:add("deps", "cmake")
        end
        if package:config("shared") then
            package:add("defines", "FMT_EXPORT")
        end
    end)

    on_install(function (package)
        if package:config("header_only") and not package:config("cmake") then
            os.cp("include/fmt", package:installdir("include"))
            return
        end

        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DFMT_TEST=OFF")
        table.insert(configs, "-DFMT_DOC=OFF")
        table.insert(configs, "-DFMT_FUZZ=OFF")
        import("package.tools.cmake").install(package, configs)
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

