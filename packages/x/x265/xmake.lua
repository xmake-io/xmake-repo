package("x265")
    set_homepage("http://x265.org")
    set_description("A free software library and application for encoding video streams into the H.265/MPEG-H HEVC compression format.")
    set_license("GPL-2.0")

    add_urls("https://bitbucket.org/multicoreware/x265_git.git",
             "https://github.com/videolan/x265.git")

    add_urls("https://github.com/videolan/x265/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_urls("https://bitbucket.org/multicoreware/x265_git/downloads/x265_$(version).tar.gz", {alias = "bitbucket"})

    add_versions("bitbucket:4.1", "a31699c6a89806b74b0151e5e6a7df65de4b49050482fe5ebf8a4379d7af8f29")
    add_versions("bitbucket:4.0", "75b4d05629e365913de3100b38a459b04e2a217a8f30efaa91b572d8e6d71282")

    add_versions("github:3.4", "544d147bf146f8994a7bf8521ed878c93067ea1c7c6e93ab602389be3117eaaf")
    add_versions("github:3.3", "ca25a38772fc6b49e5f1aa88733bc1dc92da7dc18f02a85cc3e99d76ba85b0a9")
    add_versions("github:3.2.1", "b5ee7ea796a664d6e2763f9c0ae281fac5d25892fc2cb134698547103466a06a")
    add_versions("github:3.2", "4dd707648ea90b96bf1f8ea6a36ed21c11fe3a9048923909c5b629755ca8d8f3")

    add_configs("hdr10_plus", {description = "Enable dynamic HDR10 compilation", default = false, type = "boolean"})
    add_configs("svt_hevc", {description = "Enable SVT HEVC Encoder", default = false, type = "boolean"})
    add_configs("high_bit_depth", {description = "Store pixel samples as 16bit values (Main10/Main12)", default = false, type = "boolean"})
    add_configs("main12", {description = "Support Main12 instead of Main10", default = false, type = "boolean"})
    add_configs("vmaf", {description = "Enable vmaf", default = false, type = "boolean"})
    if is_plat("linux") then
        add_configs("numa", {description = "Enable libnuma", default = false, type = "boolean"})
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_syslinks("c++")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    set_policy("package.cmake_generator.ninja", true)

    add_deps("cmake >=3.21.0", "ninja", "nasm >=2.13")

    if on_check then
        on_check("cross", function (package)
            if package:version():ge("4.0") then
                raise("package(x265 >=4.0) unsupported cross platform")
            end
        end)
    end

    on_load(function (package)
        if package:config("numa") then
            package:add("deps", "numactl")
        end
        if package:config("vmaf") then
            package:add("deps", "vmaf")
        end
    end)

    on_install(function (package)
        -- Workaround for CMake 4.0+
        for _, source in ipairs(os.files("**.txt")) do
            io.replace(source, [[VERSION 2.8.8]], [[VERSION 2.8.8...3.10]], {plain = true})
        end
        io.replace("source/CMakeLists.txt", [[if(POLICY CMP0025)]], [[if(0)]], {plain = true})
        io.replace("source/CMakeLists.txt", [[if(POLICY CMP0054)]], [[if(0)]], {plain = true})

        os.cd("source")
        -- Let xmake cp pdb
        io.replace("CMakeLists.txt", "if((WIN32 AND ENABLE_CLI) OR (WIN32 AND ENABLE_SHARED))", "if(0)", {plain = true})

        if package:is_plat("android") then
            io.replace("CMakeLists.txt", "list(APPEND PLATFORM_LIBS pthread)", "", {plain = true})
        elseif package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "X86 AND NOT X64", "FALSE", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DCHECKED_BUILD=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_PIC=" .. (package:config("pic") and "ON" or "OFF"))

        table.insert(configs, "-DENABLE_HDR10_PLUS=" .. (package:config("hdr10_plus") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SVT_HEVC=" .. (package:config("svt_hevc") and "ON" or "OFF"))
        table.insert(configs, "-DHIGH_BIT_DEPTH=" .. (package:config("high_bit_depth") and "ON" or "OFF"))
        table.insert(configs, "-DMAIN12=" .. (package:config("main12") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_CLI=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DNATIVE_BUILD=" .. (package:is_cross() and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_LIBNUMA=" .. (package:config("numa") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_VMAF=" .. (package:config("vmaf") and "ON" or "OFF"))

        if package:version() then
            table.insert(configs, "-DX265_LATEST_TAG=" .. package:version():rawstr())
        end

        if (package:is_plat("windows") and package:is_arch("arm.*"))
            or package:is_plat("android", "iphoneos", "wasm") then
            table.insert(configs, "-DENABLE_ASSEMBLY=OFF")
        end

        if package:is_cross() and package:is_targetarch("arm.*") then
            if package:is_arch64() then
                table.insert(configs, "-DCROSS_COMPILE_ARM64=ON")
            else
                table.insert(configs, "-DCROSS_COMPILE_ARM=ON")
            end
        end

        local opt = {}
        if package:gitref() or package:version():ge("4.0") then
            if package:is_plat("wasm") then
                opt.cxflags = "-pthread"
                package:add("ldflags", "-s USE_PTHREADS=1")
            end
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") then
            if package:config("shared") then
                os.tryrm(package:installdir("lib/x265-static.lib"))
            end
            -- Error links, switch to xmake pc file
            os.rm(package:installdir("lib/pkgconfig/x265.pc"))
        else
            if package:config("shared") then
                os.tryrm(package:installdir("lib/libx265.a"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x265_api_get", {includes = "x265.h"}))
    end)
