package("outcome")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ned14/outcome")
    set_description("Provides very lightweight outcome<T> and result<T> (non-Boost edition)")
    set_license("Apache-2.0")

    local versions = {
        ["v2.2.15"] = "4d43b3e74b0d8897ce37cde3d2c15b384341d9efa1e7f89c999a6a4d90f12233",
        ["v2.2.14"] = "c69d011763a7277d5ec4e53f5cfd7ba9bb9a97dc3ab870d17e647be12f4bdd0a",
        ["v2.2.13"] = "0e204b851c430bcdd5908061d5afd709d266b89d813b8c04f745474024def231",
        ["v2.2.12"] = "fd2b1c7dc3efc95c8ecf16907805a044990ea3c3dd0598a1961a2732f9c7b487",
        ["v2.2.11"] = "4a8891a6717a6d80af0e093ea9877e9f040d30fad6181f326e9306a92e2bb270",
        ["v2.2.10"] = "ea30a264d9af4be6805d42121afc9bf6156aa62abd4672ff5bfa16f7e39712e4",
        ["v2.2.9"]  = "9588c01465b287296ab647b2caf50d5137e3eeaf662e3105b858d5c5c7579428",
        ["v2.2.8"]  = "472b3df85566409ab7844f835bcab80d803dfccff1bdc74557833454dfa8e238",
        ["v2.2.7"]  = "e0f6aff453dbb8a6046ce41384557b8fc4eb477fe5be3b983d2ccec16961c40b",
        ["v2.2.4"]  = "4a36ba9c23b1fd5f001a3eea733a595d7e0eb9fe82ea0af12c103b2246f9421b"
    }
    local hashes = {
        ["v2.2.11"] = "0a91b4ef5c0ee391172998586761f306ce82ae52",
        ["v2.2.10"] = "6cf2d4345aeb57cdae00778aa80bc03609f1ae7e",
        ["v2.2.9"]  = "571f9c930e672950e99d5d30f743603aaaf8014c",
        ["v2.2.8"]  = "645500fe31c7ffc14299af9651b2ae1c9d6741c9",
        ["v2.2.7"]  = "018620768577911c9b259275a5957525d55ad09a",
        ["v2.2.4"]  = "90032f99503b4620f21d8160dc3af06fa343541f"
    }
    add_urls("https://github.com/ned14/outcome/releases/download/$(version)", {version = function (version)
        version = tostring(version)
        local hash = hashes[version]
        if hash then
            return format("%s/outcome-v2-all-sources-%s.tar.xz", version, hash)
        end
        return format("%s/outcome-v2-all-sources.tar.xz", version)
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
