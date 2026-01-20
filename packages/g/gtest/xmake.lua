package("gtest")
    set_homepage("https://github.com/google/googletest")
    set_description("Google Testing and Mocking Framework.")
    set_license("BSD-3")

    add_urls("https://github.com/google/googletest/archive/refs/tags/$(version).zip", {alias = "archive"})
    add_urls("https://github.com/google/googletest.git", {alias = "github"})

    add_versions("github:v1.8.1", "release-1.8.1")
    add_versions("archive:v1.8.1", "927827c183d01734cc5cfef85e0ff3f5a92ffe6188e0d18e909c5efebf28a0c7")
    add_versions("github:v1.10.0", "release-1.10.0")
    add_versions("archive:v1.10.0", "94c634d499558a76fa649edb13721dce6e98fb1e7018dfaeba3cd7a083945e91")
    add_versions("github:v1.11.0", "release-1.11.0")
    add_versions("archive:v1.11.0", "353571c2440176ded91c2de6d6cd88ddd41401d14692ec1f99e35d013feda55a")
    add_versions("github:v1.12.0", "release-1.12.0")
    add_versions("archive:v1.12.0", "ce7366fe57eb49928311189cb0e40e0a8bf3d3682fca89af30d884c25e983786")
    add_versions("github:v1.12.1", "release-1.12.1")
    add_versions("archive:v1.12.1", "24564e3b712d3eb30ac9a85d92f7d720f60cc0173730ac166f27dda7fed76cb2")

    add_versions("v1.13.0", "ffa17fbc5953900994e2deec164bb8949879ea09b411e07f215bfbb1f87f4632")
    add_versions("v1.14.0", "1f357c27ca988c3f7c6b4bf68a9395005ac6761f034046e9dde0896e3aba00e4")
    add_versions("v1.15.2", "f179ec217f9b3b3f3c6e8b02d3e7eda997b49e4ce26d6b235c9053bec9c0bf9f")
    add_versions("v1.16.0", "a9607c9215866bd425a725610c5e0f739eeb50887a57903df48891446ce6fb3c")
    add_versions("v1.17.0", "40d4ec942217dcc84a9ebe2a68584ada7d4a33a8ee958755763278ea1c5e18ff")

    add_configs("main",  {description = "Link to the gmock/gtest_main entry point.", default = false, type = "boolean"})
    add_configs("gmock", {description = "Link to the googlemock library.", default = true, type = "boolean"})
    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end

        if package:config("shared") and package:is_plat("windows") then
            package:add("defines", "GTEST_LINKED_AS_SHARED_LIBRARY=1")
        end

        if package:config("gmock") then
            if package:config("main") then
                package:add("links", "gmock_main")
            end
            package:add("links", "gmock")
        elseif package:config("main") then
            package:add("links", "gtest_main")
        end
        package:add("links", "gtest")
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            table.insert(configs, "-DBUILD_GMOCK=" .. (package:config("gmock") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            local std = "cxx14"
            if package:version() and package:version():gt("1.16.0") then
                std = "cxx17"
            end
            io.writefile("xmake.lua", format([[
                add_rules("utils.install.cmake_importfiles")
                set_languages("%s")
                target("gtest")
                    set_kind("$(kind)")
                    add_files("googletest/src/gtest-all.cc")
                    add_includedirs("googletest/include", "googletest")
                    add_headerfiles("googletest/include/(**.h)")
                    if is_kind("shared") and is_plat("windows") then
                        add_defines("GTEST_CREATE_SHARED_LIBRARY=1")
                    end

                target("gtest_main")
                    set_kind("$(kind)")
                    set_default(]] .. tostring(package:config("main")) .. [[)
                    add_files("googletest/src/gtest_main.cc")
                    add_includedirs("googletest/include", "googletest")
                    add_deps("gtest")

                target("gmock")
                    set_kind("$(kind)")
                    set_default(]] .. tostring(package:config("gmock")) .. [[)
                    add_files("googlemock/src/gmock-all.cc")
                    add_includedirs("googlemock/include", "googlemock", "googletest/include", "googletest")
                    add_headerfiles("googlemock/include/(**.h)")
                    if is_kind("shared") and is_plat("windows") then
                        add_defines("GTEST_CREATE_SHARED_LIBRARY=1")
                    end
                    add_deps("gtest")

                target("gmock_main")
                    set_kind("$(kind)")
                    set_default(]] .. tostring(package:config("main")) .. [[)
                    add_files("googlemock/src/gmock_main.cc")
                    add_includedirs("googlemock/include", "googlemock", "googletest/include", "googletest")
                    add_deps("gmock")
            ]], std))
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        local std = "c++14"
        if package:version() and package:version():gt("1.16.0") then
            std = "c++17"
        end
        assert(package:check_cxxsnippets({test = [[
            int factorial(int number) { return number <= 1 ? number : factorial(number - 1) * number; }
            TEST(FactorialTest, Zero) {
              testing::InitGoogleTest(0, (char**)0);
              EXPECT_EQ(1, factorial(1));
              EXPECT_EQ(2, factorial(2));
              EXPECT_EQ(6, factorial(3));
              EXPECT_EQ(3628800, factorial(10));
            }
        ]]}, {configs = {languages = std}, includes = "gtest/gtest.h"}))

        if package:config("gmock") then
            assert(package:check_cxxsnippets({test = [[
                using ::testing::AtLeast;

                class A {
                public:
                    virtual void a_foo() { return; }
                };

                class mock_A : public A {
                public:
                    MOCK_METHOD0(a_foo, void());
                };

                class B {
                public:
                    A* target;
                    B(A* param) : target(param) {}

                    bool b_foo() { target->a_foo(); return true; }
                };

                TEST(test_code, step1) {
                    mock_A a_obj;
                    B b_obj(&a_obj);

                    EXPECT_CALL(a_obj, a_foo()).Times(AtLeast(1));

                    EXPECT_TRUE(b_obj.b_foo());
                }
            ]]}, {configs = {languages = std}, includes = {"gtest/gtest.h", "gmock/gmock.h"}}))
        end
    end)
