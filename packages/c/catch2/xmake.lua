package("catch2")
    set_homepage("https://github.com/catchorg/Catch2")
    set_description("Catch2 is a multi-paradigm test framework for C++. which also supports Objective-C (and maybe C). ")
    set_license("BSL-1.0")

    add_urls("https://github.com/catchorg/Catch2/archive/refs/tags/$(version).zip",
             "https://github.com/catchorg/Catch2.git")
    add_versions("v3.12.0", "e1e1592dbc971d9196b379aef1882f7d427ceaf0ecf6cae40b575d580dd83648")
    add_versions("v3.11.0", "faa38e0b3899151d5c1b1d81f15ba7b6d25c6c27d060094212392e8f6bc1dce3")
    add_versions("v3.10.0", "e128e267ac17a7af61f57f65c31923a7b494cfe443aa7493e61033677cb7a0d3")
    add_versions("v3.9.0", "44d0c52a218d21da40800dc2d4e77f79ee6f8165ce9274fce52fa00608083912")
    add_versions("v3.8.1", "11e422a9d5a0a1732b3845ebb374c2d17e9d04337f3e717b21210be4ec2ec45b")
    add_versions("v3.8.0", "bffd2c45a84e5a4b0c17e695798e8d2f65931cbaf5c7556d40388d1d8d04eb83")
    add_versions("v3.7.1", "7d771897398704ecb61eae534912e50c4d3ec6129c4d01c174a55c29657970d7")
    add_versions("v3.7.0", "75b04c94471a70680f10f5d0d985bd1a96b8941d040d6a7bfd43f6c6b1de9daf")
    add_versions("v3.6.0", "aa0ebf551ffbf098ec1e253b5fee234c30b4ee54a31b1be63cb1a7735d3cf391")
    add_versions("v3.5.4", "190a236fe0772ac4f5eebfdebfc18f92eeecfd270c55a1e5095ae4f10be2343f")
    add_versions("v3.5.3", "2de1868288b26a19c2aebfc3fe53a748ec3ec5fc32cc742dfccaf6c685a0dc07")
    add_versions("v3.5.2", "85fcc78d0c3387b15ad82f22a94017b29e4fe7c1cf0a05c3dd465b2746eef73f")
    add_versions("v3.5.1", "b422fcd526a95e6057839f93a18099261bdc8c595f932ed4b1a978b358b3f1ed")
    add_versions("v3.5.0", "82079168b2304cfd0dfc70338f0c4b3caa4f3ef76b2643110d3f74a632252fc6")
    add_versions("v3.4.0", "cd175f5b7e62c29558d4c17d2b94325ee0ab6d0bf1a4b3d61bc8dbcc688ea3c2")
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

    if is_plat("windows") then
        add_patches("v3.5.4", path.join(os.scriptdir(), "patches", "3.5.4", "windows_arm64.patch"), "36fa29bd38fc97d3d3563bc4e7fab0810e899f8a2d8f8418555e2a4c051ad947")
    end

    add_configs("cxx17", {description = "Compiles Catch as a C++17 library (requires a C++17 compiler).", default = true, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::catch")
    elseif is_plat("linux") then
        add_extsources("pacman::catch2", "apt::catch2")
    end

    on_load(function (package)
        if package:version():ge("3.0") then
            package:add("deps", "cmake")
            package:add("components", "main", "lib")
            if package:is_plat("macosx") then
                package:add("extsources", "brew::catch2/catch2-with-main")
            end
        else
            package:set("kind", "library", {headeronly = true})
            if package:is_plat("macosx") then
                package:add("extsources", "brew::catch2")
            end
        end
    end)

    on_component("main", function (package, component)
        local link = "Catch2Main"
        if package:is_debug() then
            link = link.."d"
        end
        component:add("links", link)
    end)

    on_component("lib", function (package, component)
        local link = "Catch2"
        if package:is_debug() then
            link = link.."d"
        end
        component:add("links", link)
        if package:is_plat("windows") and package:version():le("3.0") then
            if package:has_tool("cxx", "cl", "clang-cl") then
                component:add("ldflags", "-subsystem:console")
            elseif package:has_tool("cxx", "clang", "clangxx") then
                component:add("ldflags", "-Wl,/subsystem:console")
            end
        end
    end)

    on_install(function (package)
        if package:version():ge("3.0") then
            if package:is_plat("windows") then
                local main_component = package:component("main")
                if package:has_tool("cxx", "cl", "clang-cl") then
                    main_component:add("ldflags", "-subsystem:console")
                elseif package:has_tool("cxx", "clang", "clangxx") then
                    main_component:add("ldflags", "-Wl,/subsystem:console")
                end
                os.mkdir(path.join(package:buildir(), "src/pdb"))
            end

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

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.cp(path.join(package:buildir(), "src/*.pdb"), dir)
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
