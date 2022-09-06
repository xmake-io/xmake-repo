package("grpc")
    set_homepage("https://grpc.io")
    set_description("The C based gRPC (C++, Python, Ruby, Objective-C, PHP, C#)")
    set_license("Apache-2.0")

    add_urls("https://github.com/grpc/grpc.git")
    add_versions("v1.46.3", "53d69cc581c5b7305708587f4f1939278477c28a")

    add_deps("cmake")
    if is_plat("linux") then
        add_deps("autoconf", "libtool", "pkg-config")
        add_extsources("apt::build-essential")
    elseif is_plat("macosx") then
        add_deps("autoconf", "automake", "libtool")
        add_extsources("brew::shtool")
    elseif is_plat("windows") then
        add_deps("nasm")
        add_configs("shared", {description = "Download shared libraries.", default = false, type = "boolean", readonly = true})
    end

    on_load("linux", "macosx", function (package)
        if package:config("shared") then
            package:add("links", "grpc++", "grpc++_reflection", "grpc", "gpr", "upb")
        end
    end)
    
    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_CXX_STANDARD=17")
        io.replace("third_party/boringssl-with-bazel/CMakeLists.txt", "target_link_libraries(bssl ssl crypto)", "target_link_libraries(ssl crypto)\ntarget_link_libraries(bssl ssl crypto)", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
    assert(package:check_cxxsnippets({test = [[
        void test() {
            grpc::CompletionQueue q;
        }
    ]]}, {configs = {languages = "c++17"}, includes = "grpcpp/grpcpp.h"}))
    end)
