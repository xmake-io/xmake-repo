package("llfio")
    set_homepage("https://github.com/ned14/llfio")
    set_description("UTF8-CPP: UTF-8 with C++ in a Portable Way")
    set_license("Apache-2.0")

    local versions = {
        ["2022.9.7"] = "ae7f9c5a92879285ad5100c89efc47ce1cb0031b"
    }
    add_urls("https://github.com/ned14/llfio/archive/refs/tags/all_tests_passed_$(version).tar.gz", {version = function (version)
        return versions[tostring(version)]
    end})
    add_urls("https://github.com/ned14/llfio.git")

    for version, commit in pairs(versions) do
        add_versions(version, commit)
    end
    
    add_deps("cmake")
    add_deps("quickcpplib")
    
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)
    
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <llfio/llfio.hpp>
            void test () {
                namespace llfio = LLFIO_V2_NAMESPACE;
                llfio::file_handle fh = llfio::file({}, "foo").value();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
