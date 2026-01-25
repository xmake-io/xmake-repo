package("protoc")
    set_kind("binary")
    set_homepage("https://developers.google.com/protocol-buffers/")
    set_description("Google's data interchange format compiler")

    if is_plat("android") then
        add_deps("protobuf-cpp", {configs = {tools = true}})
    else
        add_deps("protobuf-cpp")
    end

    on_install("@windows", "@linux", "@macosx", "@bsd", "@msys", function (package) end)

    on_test(function (package)
        os.vrun("protoc --version")
    end)
