package("node-api-headers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nodejs/node-api-headers")
    set_description("C-based Node-API headers")
    set_license("MIT")

    set_urls("https://github.com/nodejs/node-api-headers/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nodejs/node-api-headers.git")
    add_versions("v1.4.0", "08a96c351ab5cb0aaac55e292eb3e8b63b0b82324cb8182cc8d6c30d9bade595")
    add_versions("v1.3.0", "40f24f2088868fc564876b04547708e257fe7c445128a0c4f787dc3aa08eac9f")
    add_versions("v1.2.0", "deda1c8536ebae8b0a35c26d8547e23061c7d3cffd05ea70046be1c7c0efc2d0")
    add_versions("v1.1.0", "70608bc1e6dddce280285f3462f18a106f687c0720a4b90893e1ecd86e5a8bbf")

    on_install(function(package)
        os.cp("include/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("napi_async_init", {includes = "node_api.h"}))
    end)
