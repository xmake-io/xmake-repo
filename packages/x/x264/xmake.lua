package("x264")
    set_homepage("https://www.videolan.org/developers/x264.html")
    set_description("A free software library and application for encoding video streams into the H.264/MPEG-4 AVC compression format.")

    add_urls("https://code.videolan.org/videolan/x264.git",
             "https://github.com/mirror/x264.git")
    add_versions("v2023.04.04", "eaa68fad9e5d201d42fde51665f2d137ae96baf0")
    add_versions("v2021.09.29", "66a5bc1bd1563d8227d5d18440b525a09bcf17ca")
    add_versions("v2018.09.25", "545de2ffec6ae9a80738de1b2c8cf820249a2530")

    add_deps("nasm")

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
    add_configs("lto", {description = "enable link-time optimization", default = false, type = "boolean"})
    add_configs("pic", {description = "build position-independent code", default = false, type = "boolean"})

    -- External library support
    add_configs("avs",     {description = "enable avisynth support", default = false, type = "boolean"})
    add_configs("swscale", {description = "enable swscale support", default = false, type = "boolean"})
    add_configs("lavf",    {description = "enable libavformat support", default = false, type = "boolean"})
    add_configs("ffms",    {description = "enable ffmpegsource support", default = false, type = "boolean"})
    add_configs("gpac",    {description = "enable gpac support", default = false, type = "boolean"})
    add_configs("lsmash",  {description = "enable lsmash support", default = false, type = "boolean"})

    add_configs("toolchains", {readonly = true, description = "Set package toolchains only for cross-compilation."})

    if is_plat("linux", "macosx") then
        add_syslinks("pthread", "dl")
    end

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load("windows", "mingw", function (package)
        if is_subhost("windows") and os.arch() == "x64" then
            package:add("deps", "msys2", {configs = {msystem = "MINGW64", base_devel = true}})
        end
    end)

    on_install("windows", "mingw", "linux", "macosx", "wasm", function (package)
        local configs = {}
        table.insert(configs, "--enable-" .. (package:config("shared") and "shared" or "static"))
        if package:is_plat("wasm") then
            table.insert(configs, "--host=i686-gnu")
            package:config_set("asm", false)
            package:config_set("cli", false)
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
        if package:is_plat("windows") then
            import("core.base.option")
            import("core.tool.toolchain")
            local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
            assert(msvc:check(), "msvs not found!")
            local envs = os.joinenvs(os.getenvs(), msvc:runenvs()) -- keep msys2 envs in front to prevent conflict with possibly installed sh.exe
            envs.CC = path.filename(package:build_getenv("cc"))
            envs.SHELL = "sh"

            table.insert(configs, "--toolchain=msvc")
            table.insert(configs, "--prefix=" .. package:installdir())
            os.vrunv("./configure", configs, {shell = true, envs = envs})
            local njob = option.get("jobs") or tostring(os.default_njob())
            local argv = {"-j" .. njob}
            if option.get("verbose") then -- we always need enable it on windows, otherwise it will fail.
                table.insert(argv, "V=1")
            end
            os.vrunv("make", argv, {envs = envs})
            os.vrunv("make", {"install"}, {envs = envs})
        else
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x264_encoder_open", {includes = {"stdint.h", "x264.h"}}))
    end)
