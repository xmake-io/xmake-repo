package("capnproto")

    set_homepage("https://github.com/capnproto/capnproto")
    set_description("Cap'n Proto serialization/RPC system - core tools and C++ library.")
    set_license("MIT")

    set_urls("https://github.com/capnproto/capnproto/archive/v$(version).zip")
    add_versions("0.9.0", "18cf46aa4e05446a3d34bad8d56f9d0c73e72020a2b7548b6ec7cb7b1a828d5b")
    add_versions("0.8.0", "9a5e090b1f3ad39bb47fed5fd03672169493674ce273418b76c868393fced2e4")
    add_versions("0.7.0", "1054a879e174b8f797f1b506fedb14ecba5556c656e33ac51bd0a62bd90f925f")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake", "zlib")
    on_install("windows", "mingw@windows,msys", "linux", "macosx", "bsd", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("capnp::MallocMessageBuilder", {configs = {languages = "c++14"}, includes = "capnp/message.h"}))
    end)
