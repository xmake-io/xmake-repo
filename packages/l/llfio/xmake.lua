package("llfio")
    set_homepage("https://github.com/ned14/llfio")
    set_description("UTF8-CPP: UTF-8 with C++ in a Portable Way")
    set_license("Apache-2.0")

    local versions = {
        ["2022.9.7"] = "4ed331368afa8e7fdb2ecb02352b578c2a4c7349a8a45c1b34b85f658208a39b"
    }
    local hashes = {
        ["2022.9.7"] = "ae7f9c5a92879285ad5100c89efc47ce1cb0031b"
    }
    add_urls("https://github.com/ned14/llfio/archive/refs/tags/all_tests_passed_$(version).tar.gz", {version = function (version)
        return hashes[tostring(version)]
    end})
    add_urls("https://github.com/ned14/llfio.git")

    for version, commit in pairs(versions) do
        add_versions(version, commit)
    end

    add_cxxflags("/EHsc")
    add_deps("quickcpplib", "outcome", "ntkernel-error-category")
    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++17")
            add_requires("quickcpplib", "outcome", "ntkernel-error-category")
            target("llfio")
                set_kind("$(kind)")
                add_packages("quickcpplib", "outcome", "ntkernel-error-category")
                add_headerfiles("include/(llfio/**.hpp)")
                add_headerfiles("include/(llfio/**.ixx)")
                add_headerfiles("include/(llfio/**.h)")
                add_includedirs("include")

                if not is_kind("headeronly") then
                    add_defines("LLFIO_SOURCE=1")
                    add_files("src/*.cpp")
                else
                    add_defines("LLFIO_HEADERS_ONLY")
                    add_headerfiles("include/(llfio/**.ipp)")
                end

                remove_headerfiles("include/llfio/ntkernel-error-category/**")
        ]])
        import("package.tools.xmake").install(package)
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
