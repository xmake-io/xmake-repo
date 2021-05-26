package("fmt")

    set_homepage("https://fmt.dev")
    set_description("fmt is an open-source formatting library for C++. It can be used as a safe and fast alternative to (s)printf and iostreams.")

    set_urls("https://github.com/fmtlib/fmt/releases/download/$(version)/fmt-$(version).zip")
    add_versions("7.1.3", "5d98c504d0205f912e22449ecdea776b78ce0bb096927334f80781e720084c9f")
    add_versions("6.2.0", "a4468d528682143dcef2f16068104e03ef50467b0170b6125c9caf777d27bf10")
    add_versions("6.0.0", "b4a16b38fa171f15dbfb958b02da9bbef2c482debadf64ac81ec61b5ac422440")
    add_versions("5.3.0", "4c0741e10183f75d7d6f730b8708a99b329b2f942dad5a9da3385ab92bb4a15c")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_extsources("brew::fmt")
    end

    on_load(function (package)
        if package:config("header_only") then
            package:add("defines", "FMT_HEADER_ONLY=1")
        else
            package:add("deps", "cmake")
        end
        if package:config("shared") then
            package:add("defines", "FMT_EXPORT")
        end
    end)

    on_install(function (package)
        if package:config("header_only") then
            os.cp("include/fmt", package:installdir("include"))
            return
        end
        io.gsub("CMakeLists.txt", "MASTER_PROJECT AND CMAKE_GENERATOR MATCHES \"Visual Studio\"", "0")
        local configs = {"-DFMT_TEST=OFF", "-DFMT_DOC=OFF", "-DFMT_FUZZ=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
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
        ]]}, {configs = {languages = "c++11"}, includes = "fmt/format.h"}))
    end)

