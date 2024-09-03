package("jsoncons")

    set_kind("library", {headeronly = true})
    set_homepage("https://danielaparker.github.io/jsoncons/")
    set_description("A C++, header-only library for constructing JSON and JSON-like data formats, with JSON Pointer, JSON Patch, JSONPath, JMESPath, CSV, MessagePack, CBOR, BSON, UBJSON")
    set_license("BSL-1.0")

    set_urls("https://github.com/danielaparker/jsoncons/archive/$(version).zip",
             "https://github.com/danielaparker/jsoncons.git")

    add_versions("v0.177.0", "ce9f0ee1dbcdc67733cf9e50b038f81d36121b800f8d12a3d89ea5232457edd6")
    add_versions("v0.176.0", "71a618219b62a2bbcc46efac98696574581e343cd98ef33e5e1bd8db182005d9")
    add_versions("v0.170.2", "81ac768eecb8cf2613a09a9d081294895d7afd294b841166b4e1378f0acfdd6e")
    add_versions("v0.158.0", "7ad7cc0e9c74df495dd16b818758ec2e2a5b7fef8f1852841087fd5e8bb6a6cb")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("jsoncons::json::parse(\"\")", {configs = {languages = "c++11"}, includes = {"jsoncons/json.hpp", "jsoncons_ext/jsonpath/jsonpath.hpp"}}))
    end)
