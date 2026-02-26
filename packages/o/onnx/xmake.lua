package("onnx")
    set_homepage("https://onnx.ai/")
    set_description("Open standard for machine learning interoperability")
    set_license("Apache-2.0")

    add_urls("https://github.com/onnx/onnx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/onnx/onnx.git", {submodules = false})

    add_versions("v1.19.0", "2c2ac5a078b0350a0723fac606be8cd9e9e8cbd4c99bab1bffe2623b188fd236")
    add_versions("v1.18.0", "b466af96fd8d9f485d1bb14f9bbdd2dfb8421bc5544583f014088fb941a1d21e")
    add_versions("v1.17.0", "8d5e983c36037003615e5a02d36b18fc286541bf52de1a78f6cf9f32005a820e")
    add_versions("v1.16.2", "84fc1c3d6133417f8a13af6643ed50983c91dacde5ffba16cc8bb39b22c2acbb")
    add_versions("v1.16.1", "0e6aa2c0a59bb2d90858ad0040ea1807117cc2f05b97702170f18e6cd6b66fb3")
    add_versions("v1.16.0", "0ce153e26ce2c00afca01c331a447d86fbf21b166b640551fe04258b4acfc6a4")
    add_versions("v1.15.0", "c757132e018dd0dd171499ef74fca88b74c5430a20781ec53da19eb7f937ef68")
    add_versions("v1.11.0", "a20f2d9df805b16ac75ab4da0a230d3d1c304127d719e5c66a4e6df514e7f6c0")
    add_versions("v1.12.0", "052ad3d5dad358a33606e0fc89483f8150bb0655c99b12a43aa58b5b7f0cc507")

    add_patches(">=1.18.0", "patches/1.18.0/cmake-abseil.patch", "f7c57011c7d0c14b6b7fcbfcb99b01a20a5586f22d5a30004fbb899b55c982b6")
    add_patches(">=1.16.0<=1.17.0", "patches/1.16.0/cmake-abseil.patch", "d8cad2b231ce01aa3263692f88293be3eaa2b380e021eb5288f4c7ea930c19cb")

    add_configs("exceptions", {description = "Enable exception handling", default = true, type = "boolean"})
    add_configs("registration", {description = "Enable static registration for onnx operator schemas.", default = true, type = "boolean"})

    add_deps("cmake", "protoc", "python", {kind = "binary"})
    add_deps("protobuf-cpp")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        package:add("defines", "ONNX_ML")
        package:add("defines", "ONNX_NAMESPACE=onnx")
    end)

    on_install("!mingw", function (package)
        io.replace("CMakeLists.txt", [[set(ONNX_PROTOC_EXECUTABLE ${Protobuf_PROTOC_EXECUTABLE})]],
            "set(ONNX_PROTOC_EXECUTABLE protoc)", {plain = true})
        io.replace("cmake/Utils.cmake", "target_compile_options(${lib} PRIVATE $<$<NOT:$<CONFIG:Debug>>:/MT> $<$<CONFIG:Debug>:/MTd>)", "", {plain = true})
        io.replace("cmake/Utils.cmake", "target_compile_options(${lib} PRIVATE $<$<NOT:$<CONFIG:Debug>>:/MD> $<$<CONFIG:Debug>:/MDd>)", "", {plain = true})

        local version = package:version()

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if version and version:lt("1.16.0") then
            table.insert(configs, "-DCMAKE_CXX_STANDARD=" .. (package:is_plat("windows") and "17" or "11"))
        end
        table.insert(configs, "-DONNX_USE_PROTOBUF_SHARED_LIBS=" .. (package:dep("protobuf-cpp"):config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DONNX_DISABLE_EXCEPTIONS=" .. (package:config("exceptions") and "OFF" or "ON"))
        table.insert(configs, "-DONNX_DISABLE_STATIC_REGISTRATION=" .. (package:config("registration") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local languages = "c++11"
        if package:is_plat("windows") or (package:version() or package:version():ge("1.16.0")) then
            languages = "c++17"
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                onnx::ModelProto model;
            }
        ]]}, {configs = {languages = languages}, includes = "onnx/proto_utils.h"}))
    end)
