package("protoc")
    set_kind("binary")
    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format compiler")

    add_deps("protobuf-cpp")

    on_install(function (package) end)

    on_test(function (package)
        os.vrun("protoc --version")
    end)
