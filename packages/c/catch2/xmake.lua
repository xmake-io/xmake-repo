package("catch2")

    set_homepage("https://github.com/catchorg/Catch2")
    set_description("Catch2 is a multi-paradigm test framework for C++. which also supports Objective-C (and maybe C). ")
    set_license("BSL-1.0")

    add_urls("https://github.com/catchorg/Catch2/archive/refs/tags/$(version).zip",
             "https://github.com/catchorg/Catch2.git")
    add_versions("v3.3.2", "802a1d7f98f8e38a7913b596c5e3356ea76c544acb7c695bfd394544556359f3")
    add_versions("v3.2.1", "bfee681eaa920c6ddbe05c1eef1912440d38c5f9a7924f68a6aa219ed1a39c0f")
    add_versions("v3.2.0", "b9f3887915f32eb732140af6a153065a11fabcd3f3e9355f3abff3d3618fd0fe")
    add_versions("v3.1.1", "eec6c327cd9187c63bbaaa8486f715e31544000bf8876c0543e1181a2a52a5de")
    add_versions("v3.1.0", "7219c2ca75a6b2a157b1b162e4ad819fb32585995cac32542a4f72d950dd96f7")
    add_versions("v2.13.10", "121e7488912c2ce887bfe4699ebfb983d0f2e0d68bcd60434cdfd6bb0cf78b43")
    add_versions("v2.13.9", "860e3917f07d7ee75654f86900d50a03acf0047f6fe5ba31d437e1e9cda5b456")
    add_versions("v2.13.8", "de0fd1f4c51a1021ffcb33a4d42028545bf1a0665a4ab59ddb839a0cc93f03a5")
    add_versions("v2.13.7", "3f3ccd90ad3a8fbb1beeb15e6db440ccdcbebe378dfd125d07a1f9a587a927e9")
    add_versions("v2.13.6", "39d50f5d1819cdf2908066664d57c2cde4a4000c364ad3376ea099735c896ff4")
    add_versions("v2.13.5", "728679b056dc1248cc79b3a1999ff7453f76422c68417563fc47a0ac2aaeeaef")
    add_versions("v2.9.2", "dc486300de22b0d36ddba1705abb07b9e5780639d824ba172ddf7062b2a1bf8f")

    add_configs("cxx17", {description = "Compiles Catch as a C++17 library (requires a C++17 compiler).", default = true, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::catch")
    elseif is_plat("linux") then
        add_extsources("pacman::catch2-git", "apt::catch2")
    elseif is_plat("macosx") then
        add_extsources("brew::catch2")
    end

    on_load(function (package)
        if package:version():ge("3.0") then
            package:add("deps", "cmake")
            package:add("components", "main", "lib")
        else
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_component("main", function (package, component)
        local link = "Catch2Main"
        if package:is_debug() then
            link = link.."d"
        end
        component:add("links", link)
        if package:is_plat("windows") then
            component:add("ldflags", "-subsystem:console")
        end
    end)

    on_component("lib", function (package, component)
        local link = "Catch2"
        if package:is_debug() then
            link = link.."d"
        end
        component:add("links", link)
    end)

    on_install(function (package)
        if package:version():ge("3.0") then
            local configs = {"-DCATCH_INSTALL_DOCS=OFF", "-DCATCH_BUILD_TESTING=OFF", "-DCATCH_BUILD_EXAMPLES=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            if package:config("cxx17") then
                table.insert(configs, "-DCMAKE_CXX_STANDARD=17")
            end
            import("package.tools.cmake").install(package, configs)
        else
            os.cp("single_include/catch2", package:installdir("include"))
        end
    end)

    on_test(function (package)
        if package:version():ge("3.0") then
            assert(package:check_cxxsnippets({test = [[
                int factorial(int number) { return number <= 1 ? number : factorial(number - 1) * number; }

                TEST_CASE("Factorials are computed", "[factorial]") {
                    REQUIRE(factorial(1) == 1);
                    REQUIRE(factorial(2) == 2);
                    REQUIRE(factorial(3) == 6);
                    REQUIRE(factorial(10) == 3628800);
                }
            ]]}, {configs = {languages = "c++14"}, includes = "catch2/catch_test_macros.hpp"}))
        else
            assert(package:check_cxxsnippets({test = [[
                int factorial(int number) { return number <= 1 ? number : factorial(number - 1) * number; }

                TEST_CASE("testing the factorial function") {
                    CHECK(factorial(1) == 1);
                    CHECK(factorial(2) == 2);
                    CHECK(factorial(3) == 6);
                    CHECK(factorial(10) == 3628800);
                }
            ]]}, {configs = {languages = "c++11"}, includes = "catch2/catch.hpp", defines = "CATCH_CONFIG_MAIN"}))
        end
    end)
