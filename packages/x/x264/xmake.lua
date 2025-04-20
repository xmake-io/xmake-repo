package("x264")
    set_homepage("https://www.videolan.org/developers/x264.html")
    set_description("A free software library and application for encoding video streams into the H.264/MPEG-4 AVC compression format.")
    set_license("GPL-2.0")

    add_urls("https://code.videolan.org/videolan/x264.git",
             "https://github.com/mirror/x264.git")

    add_versions("v2024.02.27", "c24e06c2e184345ceb33eb20a15d1024d9fd3497")
    add_versions("v2023.04.04", "eaa68fad9e5d201d42fde51665f2d137ae96baf0")
    add_versions("v2021.09.29", "66a5bc1bd1563d8227d5d18440b525a09bcf17ca")
    add_versions("v2018.09.25", "545de2ffec6ae9a80738de1b2c8cf820249a2530")

    add_configs("cli",            {description = "enable cli", default = false, type = "boolean"})
    add_configs("bashcompletion", {description = "enable installation of bash-completion script", default = false, type = "boolean"})
    add_configs("opencl",         {description = "enable OpenCL features", default = true, type = "boolean"})
    add_configs("gpl",            {description = "enable GPL-only features", default = false, type = "boolean"})
    add_configs("thread",         {description = "enable multithreaded encoding", default = true, type = "boolean"})
    add_configs("interlaced",     {description = "enable interlaced encoding support", default = true, type = "boolean"})
    add_configs("bit-depth",      {description = "set output bit depth", default = "all", value = {8, 10, "all"}})
    add_configs("chroma-format",  {description = "output chroma format", default = "all", value = {400, 420, 422, 444, "all"}})

    -- Advanced options
    add_configs("asm", {description = "enable platform-specific assembly optimizations", default = true, type = "boolean"})

    -- External library support
    add_configs("avs",     {description = "enable avisynth support", default = false, type = "boolean"})
    add_configs("swscale", {description = "enable swscale support", default = false, type = "boolean"})
    add_configs("lavf",    {description = "enable libavformat support", default = false, type = "boolean"})
    add_configs("ffms",    {description = "enable ffmpegsource support", default = false, type = "boolean"})
    add_configs("gpac",    {description = "enable gpac support", default = false, type = "boolean"})
    add_configs("lsmash",  {description = "enable lsmash support", default = false, type = "boolean"})

    add_configs("toolchains", {readonly = true, description = "Set package toolchains only for cross-compilation."})

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "macosx", "bsd") then
        add_syslinks("pthread", "dl")
    end

    add_deps("nasm")

    on_load(function (package)
        if is_subhost("windows") and os.arch() == "x64" then
            local msystem = "MINGW" .. (package:is_targetarch("i386", "x86", "i686") and "32" or "64")
            package:add("deps", "msys2", {configs = {msystem = msystem, base_devel = true}})
        end

        if package:config("shared") then
            package:add("defines", "X264_API_IMPORTS")
        end
    end)

    on_install("!iphoneos and !bsd", function (package)
        if is_host("windows") then
            io.replace("Makefile",
                "ln -f -s $(SONAME) $(DESTDIR)$(libdir)/libx264.$(SOSUFFIX)",
                "mv $(SONAME) libx264.$(SOSUFFIX)", {plain = true})
            io.replace("Makefile",
                "$(INSTALL) -m 755 $(SONAME) $(DESTDIR)$(libdir)",
                "$(INSTALL) -m 755 libx264.$(SOSUFFIX) $(DESTDIR)$(libdir)", {plain = true})
        end

        if package:is_plat("android") and package:is_arch("armeabi-v7a") then
            local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
            if ndk_sdkver and tonumber(ndk_sdkver) < 24 then
                io.replace("configure", "define fseek fseek", "", {plain = true})
                io.replace("configure", "define ftell ftell", "", {plain = true})
            end
        end

        local configs = {}
        table.insert(configs, "--enable-" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "--" .. (package:is_debug() and "enable" or "disable") .. "-debug")
        table.insert(configs, "--" .. (package:config("lto") and "enable" or "disable") .. "-lto")
        table.insert(configs, "--" .. (package:config("pic") and "enable" or "disable") .. "-pic")

        if package:is_plat("wasm") then
            table.insert(configs, "--host=i686-gnu")
            package:config_set("asm", false)
            package:config_set("cli", false)
        elseif package:is_plat("android") then
            local ndk_bindir = package:toolchain("ndk"):config("bindir")
            ndk_bindir = path.unix(assert(ndk_bindir)) .. "/llvm-"
            table.insert(configs, "--cross-prefix=" .. ndk_bindir)
        elseif package:is_plat("mingw") then
            local triples = {
                i386   = "i686-w64-mingw32",
                x86_64 = "x86_64-w64-mingw32"
            }
            table.insert(configs, "--host=" .. (triples[package:arch()] or triples.i386))
            if not is_host("windows") then
                package:config_set("asm", false)
            end
        end

        for name, value in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if type(value) == "boolean" then
                    table.insert(configs, "--" .. (value and "enable" or "disable") .. "-" .. name)
                else
                    table.insert(configs, "--" .. name .. "=" .. value)
                end
            end
        end

        local opt = {}
        if package:is_plat("windows") then
            import("core.base.option")
            import("core.tool.toolchain")

            local msvc = package:toolchain("msvc") or toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
            assert(msvc:check(), "msvs not found!")
            io.replace("configure", "x264.dll.lib", "x264.lib", {plain = true})

            -- keep msys2 envs in front to prevent conflict with possibly installed sh.exe
            local envs = os.joinenvs(os.getenvs(), msvc:runenvs())
            envs.CC = path.filename(package:build_getenv("cc"))
            envs.SHELL = "sh"

            table.insert(configs, "--toolchain=msvc")
            table.insert(configs, "--prefix=" .. path.unix(package:installdir()))
            opt.envs = envs
        end
        import("package.tools.autoconf").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x264_encoder_open", {includes = {"stdint.h", "x264.h"}}))
    end)
