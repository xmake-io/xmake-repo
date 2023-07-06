package("x265")
    set_homepage("http://x265.org")
    set_description("A free software library and application for encoding video streams into the H.265/MPEG-H HEVC compression format.")
    set_license("GPL-2.0")

    add_urls("https://github.com/videolan/x265/archive/$(version).tar.gz",
             "https://github.com/videolan/x265.git",
             "https://bitbucket.org/multicoreware/x265_git")

    add_versions("3.2", "4dd707648ea90b96bf1f8ea6a36ed21c11fe3a9048923909c5b629755ca8d8f3")
    add_versions("3.2.1", "b5ee7ea796a664d6e2763f9c0ae281fac5d25892fc2cb134698547103466a06a")
    add_versions("3.3", "ca25a38772fc6b49e5f1aa88733bc1dc92da7dc18f02a85cc3e99d76ba85b0a9")
    add_versions("3.4", "544d147bf146f8994a7bf8521ed878c93067ea1c7c6e93ab602389be3117eaaf")
    
    add_configs("hdr10_plus", {description = "Enable dynamic HDR10 compilation", default = false, type = "boolean"})
    add_configs("svt_hevc", {description = "Enable SVT HEVC Encoder", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    else
        add_deps("nasm >=2.13")
    end

    if is_plat("macosx") then
        add_syslinks("c++")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_install("windows|x86", "windows|x64", "mingw", "linux", "bsd", "macosx", "wasm", "cross", function (package)
        os.cd("source")
        if package:is_plat("android") then
            io.replace("CMakeLists.txt", "list(APPEND PLATFORM_LIBS pthread)", "", { plain = true })
        end
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "X86 AND NOT X64", "FALSE")
        end
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_HDR10_PLUS=" .. (package:config("hdr10_plus") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SVT_HEVC=" .. (package:config("svt_hevc") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_cross() and package:is_targetarch("arm.*") then
            table.insert(configs, "-DCROSS_COMPILE_ARM=ON")
            if not package:is_plat("android") then
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. (package:is_targetarch("aarch64", "arm64") and "aarch64" or "armv6l"))
                table.insert(configs, "-DCMAKE_SIZEOF_VOID_P=" .. (package:is_targetarch("aarch64", "arm64") and "8" or "4"))
            end
        end
        if package:version() then
            table.insert(configs, "-DX265_LATEST_TAG=" .. package:version():rawstr())
        end
        table.insert(configs, "--trace")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x265_api_get", {includes = "x265.h"}))
    end)
