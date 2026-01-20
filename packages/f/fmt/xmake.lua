package("fmt")
    set_homepage("https://fmt.dev")
    set_description("fmt is an open-source formatting library for C++. It can be used as a safe and fast alternative to (s)printf and iostreams.")
    set_license("MIT")

    set_urls("https://github.com/fmtlib/fmt/releases/download/$(version)/fmt-$(version).zip",
             "https://github.com/fmtlib/fmt.git")

    add_versions("12.1.0", "695fd197fa5aff8fc67b5f2bbc110490a875cdf7a41686ac8512fb480fa8ada7")
    add_versions("12.0.0", "1c32293203449792bf8e94c7f6699c643887e826f2d66a80869b4f279fb07d25")
    add_versions("11.2.0", "203eb4e8aa0d746c62d8f903df58e0419e3751591bb53ff971096eaa0ebd4ec3")
    add_versions("11.1.4", "49b039601196e1a765e81c5c9a05a61ed3d33f23b3961323d7322e4fe213d3e6")
    add_versions("11.1.3", "7df2fd3426b18d552840c071c977dc891efe274051d2e7c47e2c83c3918ba6df")
    add_versions("11.1.2", "ef54df1d4ba28519e31bf179f6a4fb5851d684c328ca051ce5da1b52bf8b1641")
    add_versions("11.1.1", "a25124e41c15c290b214c4dec588385153c91b47198dbacda6babce27edc4b45")
    add_versions("11.1.0", "e32d42c6be8df768d744bf0e7d4d69c4ccdce0eda44292ba5265add817413f17")
    add_versions("11.0.2", "40fc58bebcf38c759e11a7bd8fdc163507d2423ef5058bba7f26280c5b9c5465")
    add_versions("11.0.1", "62ca45531814109b5d6cef0cf2fd17db92c32a30dd23012976e768c685534814")
    add_versions("11.0.0", "583ce480ef07fad76ef86e1e2a639fc231c3daa86c4aa6bcba524ce908f30699")
    add_versions("10.2.1", "312151a2d13c8327f5c9c586ac6cf7cddc1658e8f53edae0ec56509c8fa516c9")
    add_versions("10.2.0", "8a942861a94f8461a280f823041cde8f620a6d8b0e0aacc98c15bb5a9dd92399")
    add_versions("10.1.1", "b84e58a310c9b50196cda48d5678d5fa0849bca19e5fdba6b684f0ee93ed9d1b")
    add_versions("10.1.0", "d725fa83a8b57a3cedf238828fa6b167f963041e8f9f7327649bddc68ae316f4")
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

    add_patches("10.1.0", "patches/10.1.0/utf8.patch", "3280569bced9ec08933f0ea37b6a4fef4538944d9046fe197ad63e22d1357cd4")

    add_configs("header_only", {description = "Use header only version.", default = false, type = "boolean"})
    add_configs("unicode", {description = "Enable Unicode support.", default = true, type = "boolean"})

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
            package:set("kind", "library", {headeronly = true})
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
        if not package:config("unicode") then
            package:add("defines", "FMT_UNICODE=0")
        end
    end)

    on_install(function (package)
        if package:has_tool("cxx", "cl") and package:config("unicode") then
            package:add("cxxflags", "/utf-8")
        end
        if package:config("header_only") then
            os.cp("include/fmt", package:installdir("include"))
            return
        end
        io.gsub("CMakeLists.txt", "MASTER_PROJECT AND CMAKE_GENERATOR MATCHES \"Visual Studio\"", "0")
        local configs = {"-DFMT_TEST=OFF", "-DFMT_DOC=OFF", "-DFMT_FUZZ=OFF", "-DCMAKE_CXX_VISIBILITY_PRESET=default"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DFMT_UNICODE=" .. (package:config("unicode") and "ON" or "OFF"))
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
