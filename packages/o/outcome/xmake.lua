package("outcome")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ned14/outcome")
    set_description("Provides very lightweight outcome<T> and result<T> (non-Boost edition)")
    set_license("Apache-2.0")

    local versions = {
        ["v2.2.4"] = "4a36ba9c23b1fd5f001a3eea733a595d7e0eb9fe82ea0af12c103b2246f9421b"
    }
    local hashes = {
        ["v2.2.4"] = "90032f99503b4620f21d8160dc3af06fa343541f"
    }
    add_urls("https://github.com/ned14/outcome/releases/download/$(version)", {version = function (version)
        return format("%s/outcome-v2-all-sources-%s.tar.xz", version, hashes[tostring(version)])
    end})
    add_urls("https://github.com/ned14/outcome.git")

    for version, commit in pairs(versions) do
        add_versions(version, commit)
    end

    add_deps("quickcpplib")
    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("quickcpplib")
            target("outcome")
                set_kind("headeronly")
                add_packages("quickcpplib")
                add_headerfiles("include/(outcome/**.hpp)")
                add_headerfiles("include/(outcome/**.ixx)")
                add_headerfiles("include/(outcome/**.ipp)")
                add_headerfiles("include/(outcome/**.h)")
                add_includedirs("include")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        local cxxflags = package:has_tool("cxx", "clang", "clangxx") and {"-fsized-deallocation"} or {}
        assert(package:check_cxxsnippets({test = [[
            #include <outcome/outcome.hpp>
            void test () {
                using namespace OUTCOME_V2_NAMESPACE;
                result<int> f(5);
                outcome<void> m(in_place_type<void>);
                (void) f;
                (void) m;
            }
        ]]}, {configs = {languages = "c++17", cxxflags = cxxflags}}))
    end)
