package("jsoncons")
    set_kind("library", {headeronly = true})
    set_homepage("https://danielaparker.github.io/jsoncons/")
    set_description("A C++, header-only library for constructing JSON and JSON-like data formats, with JSON Pointer, JSON Patch, JSONPath, JMESPath, CSV, MessagePack, CBOR, BSON, UBJSON")
    set_license("BSL-1.0")

    set_urls("https://github.com/danielaparker/jsoncons/archive/refs/tags/$(version).tar.gz",
             "https://github.com/danielaparker/jsoncons.git")

    add_versions("v1.5.0", "956021e44e50639be766a4ad71aff9a95168da188005fc6bfa23ee5d6a53eb32")
    add_versions("v1.4.3", "6cc79df3bf10f3ecd5fbdd0a64deaaad35beda2767f8697e261e1af11e1e3526")
    add_versions("v1.3.2", "f22fb163df1a12c2f9ee5f95cad9fc37c6cfbefe0ae6f30aba7440832ef70fbe")
    add_versions("v1.3.0", "7a485c2af0ff214b62bb00f5a1487e5a0c4997eadc6ee9155ce3e8c9d05b9d7a")
    add_versions("v1.2.0", "3bdc0c8ceba1943b5deb889559911ebe97377971453a11227ed0a51a05e5d5d8")
    add_versions("v1.1.0", "073f6f40d92715f4540e43997df22a89018afb8f25914f9d889bb21be818532e")
    add_versions("v1.0.0", "5b602e131761a3eb0fc85043a67e8006f04fa0ce2f2012aeca48371cd99ec85f")
    add_versions("v0.178.0", "c531b4288bb08c9c2b36fba53f568bc800e93656830bcffc18a87a3af1f46290")
    add_versions("v0.177.0", "a381d58489f143a3a515484f4ad6e32ae4d977033e1a455fecf8cdc4e2c9a49e")
    add_versions("v0.176.0", "2eb50b5cbe204265fef96c052511ed6e3b8808935c6e2c8d28e0aba7b08fda33")
    add_versions("v0.170.2", "0ff0cd407f6b27dea66a3202bc8bc2e043ec1614419e76840eda5b5f8045a43a")

    add_configs("cmake", {description = "Use cmake build system", default = true, type = "boolean"})

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) >= 28, "package(jsoncons): require ndk api level >= 28")
        end)
    end

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            import("package.tools.cmake").install(package, {
                "-DJSONCONS_BUILD_TESTS=OFF",
                "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
            })
        else
            os.cp("include", package:installdir())
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("jsoncons::json::parse(\"\")", {configs = {languages = "c++11"}, includes = {"jsoncons/json.hpp", "jsoncons_ext/jsonpath/jsonpath.hpp"}}))
    end)
