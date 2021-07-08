package("capnproto")

    set_homepage("https://github.com/capnproto/capnproto")
    set_description("Cap'n Proto serialization/RPC system - core tools and C++ library.")

    set_urls("https://github.com/capnproto/capnproto/archive/v$(version).zip")
    add_versions("0.8.0", "9a5e090b1f3ad39bb47fed5fd03672169493674ce273418b76c868393fced2e4")
    add_versions("0.7.0", "1054a879e174b8f797f1b506fedb14ecba5556c656e33ac51bd0a62bd90f925f")

    add_deps("zlib")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_TESTING=OFF")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("capnp::MallocMessageBuilder", {configs = {languages = "c++11"}, includes = "capnp/message.h"}))
    end)
