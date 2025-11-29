package("cwt-cucumber")
    set_homepage("https://github.com/ThoSe1990/cwt-cucumber")
    set_description("A C++ Cucumber interpreter")
    set_license("MIT")

    add_urls("https://github.com/ThoSe1990/cwt-cucumber/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ThoSe1990/cwt-cucumber.git")

    add_versions("2.8", "30576a39a9ce2c4a915ed8f0e46f3f0ef149febf995989dfb02a05866ff38f57")
    add_versions("2.7", "12a38587fc50990dbb7f80a18e401011ea8d7e5d1dd82a13e66cb294a02bbd78")
    add_versions("2.6", "1896f695b06dccf30d030ea819f693e4324bbd2f38f336aa36cf6fa87be3dfbd")
    add_versions("2.5", "793d07c2f1989a2943befd4344cb8a49f36d39bdc0d596dbebbbc50e25fa3bc5")

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_check("android", function (package)
        local ndk = package:toolchain("ndk"):config("ndkver")
        assert(ndk and tonumber(ndk) > 22, "package(cwt-cucumber) require ndk version > 22")
    end)

    on_check("macosx", function (package)
        if macos.version():le("14") then
            raise("package(cwt-cucumber): requires macOS version >= 14.5")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(${PROJECT_SOURCE_DIR}/examples)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(${PROJECT_SOURCE_DIR}/gtest)", "", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        struct foo {
            std::string word;
            std::string anonymous;
        };
        WHEN(word_anonymous_given, "A {word} and {}") {
            std::string word = CUKE_ARG(1);
            cuke::context<foo>().word = word;
            std::string anonymous = CUKE_ARG(2);
            cuke::context<foo>().anonymous = anonymous;
        }
        THEN(word_anonymous_then, "They will match {string} and {string}") {
            std::string expected_word = CUKE_ARG(1);
            std::string expected_anonymous = CUKE_ARG(2);
            cuke::equal(expected_word, cuke::context<foo>().word);
            cuke::equal(expected_anonymous, cuke::context<foo>().anonymous);
        }
        ]]}, {configs = {languages = "c++20"}, includes = {"cwt-cucumber/cucumber.hpp"}}))
    end)
