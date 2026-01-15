package("protoc")
    set_kind("binary")
    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format compiler")

    add_deps("protobuf-cpp", {configs = {tools = true}})

    on_install("@windows|x86", "@windows|x64", "@windows|arm64*", "@msys", "@cygwin", "@macosx", "@bsd", "@linux", function (package) end)

    on_test(function (package)
        os.vrun("protoc --version")
    end)
