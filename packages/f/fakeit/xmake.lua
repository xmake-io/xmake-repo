package("fakeit")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/eranpeer/FakeIt")
    set_description("C++ mocking made easy. A simple yet very expressive, headers only library for c++ mocking.")
    set_license("MIT")

    add_urls("https://github.com/eranpeer/FakeIt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eranpeer/FakeIt.git")

    add_versions("2.5.0", "57adedf802271513d88a1d9342d829cfb34988c3d835e07346f8129047200c53")
    add_versions("2.4.1", "f5234a36d42363cb7ccd2cf99c8a754c832d9092035d984ad40aafa5371d0e95")
    add_versions("2.4.0", "eb79459ad6a97a5c985e3301b0d44538bdce2ba26115afe040f3874688edefb5")

    local test_frameworks = {
        "gtest",
        "mstest",
        "boost",
        "catch",
        "tpunit",
        "mettle",
        "qtest",
        "nunit",
        "cute",
        "doctest",
        "standalone",
    }

    add_configs("framework", {description = "Choose test library to use", default = "standalone", type = "string", values = test_frameworks})

    on_load(function (package)
        local framework = package:config("framework")
        if framework == "gtest" then
            package:add("deps", "gtest")
        elseif framework == "boost" then
            package:add("deps", "boost", {configs = {test = true}})
        elseif framework == "catch" then
            package:add("deps", "catch2")
        elseif framework == "doctest" then
            package:add("deps", "doctest")
        end
    end)

    on_install(function (package)
        os.vcp(path.join("single_header", package:config("framework"), "*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            struct SomeInterface {
                virtual int foo(int) = 0;
            };
            void test() {
                fakeit::Mock<SomeInterface> mock;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "fakeit.hpp"}))
    end)
