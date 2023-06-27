package("fmt")

    set_homepage("https://fmt.dev")
    set_description("fmt is an open-source formatting library for C++. It can be used as a safe and fast alternative to (s)printf and iostreams.")

    set_urls("https://github.com/fmtlib/fmt/releases/download/$(version)/fmt-$(version).zip",
             "https://github.com/fmtlib/fmt.git")
    add_versions("10.0.0", "4943cb165f3f587f26da834d3056ee8733c397e024145ca7d2a8a96bb71ac281")
    add_versions("9.1.0", "cceb4cb9366e18a5742128cb3524ce5f50e88b476f1e54737a47ffdf4df4c996")
    add_versions("9.0.0", "fc96dd2d2fdf2bded630787adba892c23cb9e35c6fd3273c136b0c57d4651ad6")    
    add_versions("8.1.1", "23778bad8edba12d76e4075da06db591f3b0e3c6c04928ced4a7282ca3400e5d")
    add_versions("8.0.1", "a627a56eab9554fc1e5dd9a623d0768583b3a383ff70a4312ba68f94c9d415bf")
    add_versions("8.0.0", "36016a75dd6e0a9c1c7df5edb98c93a3e77dabcf122de364116efb9f23c6954a")
    add_versions("7.1.3", "5d98c504d0205f912e22449ecdea776b78ce0bb096927334f80781e720084c9f")
    add_versions("6.2.0", "a4468d528682143dcef2f16068104e03ef50467b0170b6125c9caf777d27bf10")
    add_versions("6.0.0", "b4a16b38fa171f15dbfb958b02da9bbef2c482debadf64ac81ec61b5ac422440")
    add_versions("5.3.0", "4c0741e10183f75d7d6f730b8708a99b329b2f942dad5a9da3385ab92bb4a15c")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::fmt")
    elseif is_plat("linux") then
        add_extsources("pacman::fmt", "apt::libfmt-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::fmt")
    end

    on_load(function (package)
        if package:config("header_only") then
            package:add("defines", "FMT_HEADER_ONLY=1")
        else
            package:add("deps", "cmake")
        end
        if package:config("shared") then
            local version = package:version()
            if version and version:ge("10") then
                package:add("defines", "FMT_LIB_EXPORT")
            else
                package:add("defines", "FMT_EXPORT")
            end
        end
    end)

    on_install(function (package)
        if package:config("header_only") then
            os.cp("include/fmt", package:installdir("include"))
            return
        end
        io.gsub("CMakeLists.txt", "MASTER_PROJECT AND CMAKE_GENERATOR MATCHES \"Visual Studio\"", "0")
        local configs = {"-DFMT_TEST=OFF", "-DFMT_DOC=OFF", "-DFMT_FUZZ=OFF", "-DCMAKE_CXX_VISIBILITY_PRESET=default"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
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
        ]]}, {configs = {languages = "c++14"}, includes = "fmt/format.h"}))
    end)

