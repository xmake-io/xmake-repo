package("node-api-headers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nodejs/node-api-headers")
    set_description("C-based Node-API headers")
    set_license("MIT")

    set_urls("https://github.com/nodejs/node-api-headers/archive/refs/tags/$(version).tar.gz",
        "https://github.com/nodejs/node-api-headers.git")
    add_versions("v1.1.0", "70608bc1e6dddce280285f3462f18a106f687c0720a4b90893e1ecd86e5a8bbf")

    on_install(function(package)
        os.cp("include/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("napi_status", {includes = "node_api.h"}))
    end)
