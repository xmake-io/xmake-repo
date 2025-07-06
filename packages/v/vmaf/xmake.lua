package("vmaf")
    set_homepage("https://github.com/Netflix/vmaf")
    set_description("Perceptual video quality assessment based on multi-method fusion.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/Netflix/vmaf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Netflix/vmaf.git")

    add_versions("v3.0.0", "7178c4833639e6b989ecae73131d02f70735fdb3fc2c7d84bc36c9c3461d93b1")

    add_configs("asm", {description = "Build asm files", default = false, type = "boolean"})
    add_configs("avx512", {description = "Build AVX-512 asm files, requires nasm 2.14", default = false, type = "boolean"})
    add_configs("built_in_models", {description = "Compile default vmaf models", default = false, type = "boolean"})
    add_configs("float", {description = "Compile floating-point feature extractors", default = false, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA support", default = false, type = "boolean"})
    add_configs("nvtx", {description = "Enable NVTX range support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::vmaf")
    elseif is_plat("linux") then
        add_extsources("pacman::vmaf")
    elseif is_plat("macosx") then
        add_extsources("brew::libvmaf")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("meson", "ninja")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndkver = ndk:config("ndkver")
            assert(ndkver and tonumber(ndkver) > 22, "package(vmaf) require ndk version > 22")
            if package:is_arch("armeabi-v7a") then
                local ndk_sdkver = ndk:config("ndk_sdkver")
                assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(vmaf/armeabi-v7a) require ndk api level > 21")
            end
        end)
    end

    on_load(function (package)
        if package:config("asm") or package:config("avx512") then
            package:add("deps", "nasm")
        end

        if package:config("cuda") then
            package:add("deps", "cuda")
        end

        if package:config("nvtx") then
            package:add("syslinks", "dl")
        end
    end)

    on_install("!windows", function (package)
        os.cd("libvmaf")
        if not package:config("tools") then
            io.replace("meson.build", [[subdir('tools')]], "", {plain = true})
        end

        local configs = {"-Denable_tests=false", "-Denable_docs=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        table.insert(configs, "-Denable_asm=" .. (package:config("asm") and "true" or "false"))
        table.insert(configs, "-Denable_avx512=" .. (package:config("avx512") and "true" or "false"))
        table.insert(configs, "-Dbuilt_in_models=" .. (package:config("built_in_models") and "true" or "false"))
        table.insert(configs, "-Denable_float=" .. (package:config("float") and "true" or "false"))
        table.insert(configs, "-Denable_cuda=" .. (package:config("cuda") and "true" or "false"))
        table.insert(configs, "-Denable_nvtx=" .. (package:config("nvtx") and "true" or "false"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vmaf_init", {includes = "libvmaf/libvmaf.h"}))
    end)
