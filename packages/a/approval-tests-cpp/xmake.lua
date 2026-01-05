package("approval-tests-cpp")
    set_homepage("https://approvaltestscpp.readthedocs.io/en/latest/")
    set_description("Native ApprovalTests for C++ on Linux, Mac and Windows")
    set_license("Apache-2.0")

    add_urls("https://github.com/approvals/ApprovalTests.cpp/releases/download/$(version)/ApprovalTests.$(version).hpp", {
        alias = "amalgamate",
        version = function(version)
            return version:gsub("%v", "v.")
    end})
    add_urls("https://github.com/approvals/ApprovalTests.cpp/archive/refs/tags/$(version).tar.gz", {version = function(version)
        return version:gsub("%v", "v.")
    end})
    add_urls("https://github.com/approvals/ApprovalTests.cpp.git", {alias = "git"})

    add_versions("v10.13.0", "44896af00018fc051f0332d7a78e4b8caf4274d2e51e6ba786e6271575fb82c8")

    add_versions("git:v10.13.0", "v.10.13.0")

    add_versions("amalgamate:v10.13.0", "c00f6390b81d9924dc646e9d32b61e1e09abda106c13704f714ac349241bb9ff")

    add_deps("cmake")

    on_install(function (package)
        if os.isfile("CMakeLists.txt") then
            io.replace("ApprovalTests/CMakeLists.txt", "include(WarningsAsErrors)", "", {plain = true})

            local configs = {
                "-DAPPROVAL_TESTS_BUILD_TESTING=OFF",
                "-DAPPROVAL_TESTS_BUILD_EXAMPLES=OFF",
                "-DAPPROVAL_TESTS_BUILD_DOCS=OFF",
                "-DPROJECT_NAME=xmake",
            }
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
            import("package.tools.cmake").install(package, configs)
        else
            package:set("kind", "library", {headeronly = true})
            os.vcp(package:originfile(), path.join(package:installdir("include/ApprovalTests"), "ApprovalTests.hpp"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            #include <ApprovalTests/ApprovalTests.hpp>
            void test() {
                std::cout << ApprovalTests::StringMaker::toString(42) << std::endl;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
