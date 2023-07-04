package("libvpx")
    set_homepage("http://www.webmproject.org/code/")
    set_description("VP8/VP9 Codec SDK")
    set_license("BSD-3")

    add_urls("https://github.com/webmproject/libvpx.git",
        "https://chromium.googlesource.com/webm/libvpx.git",
        "https://github.com/webmproject/libvpx/archive/refs/tags/v$(version).tar.gz")

    add_versions("1.10.0", "85803ccbdbdd7a3b03d930187cb055f1353596969c1f92ebec2db839fa4f834a")
    add_versions("1.11.0", "965e51c91ad9851e2337aebcc0f517440c637c506f3a03948062e3d5ea129a83")
    add_versions("1.12.0", "f1acc15d0fd0cb431f4bf6eac32d5e932e40ea1186fe78e074254d6d003957bb")
    add_versions("1.13.0", "cb2a393c9c1fae7aba76b950bb0ad393ba105409fe1a147ccd61b0aaa1501066")

    add_configs("examples",         {description = "examples", default = false, type = "boolean"})
    add_configs("tools",            {description = "tools", default = false, type = "boolean"})
    add_configs("docs",             {description = "documentation", default = false, type = "boolean"})
    add_configs("unit-tests",       {description = "unit tests", default = false, type = "boolean"})

    add_configs("vp8",              {description = "VP8 codec support", default = true, type = "boolean"})
    add_configs("vp9",              {description = "VP9 codec support", default = true, type = "boolean"})
    add_configs("multithread",      {description = "multithreaded encoding and decoding", default = true, type = "boolean"})
    add_configs("webm-io",          {description = "enable input from and output to WebM container", default = false, type = "boolean"})
    add_configs("libyuv",           {description = "enable libyuv", default = false, type = "boolean"})
    add_configs("postproc",         {description = "postprocessing", default = false, type = "boolean"})
    add_configs("vp9-postproc",     {description = "vp9 specific postprocessing", default = false, type = "boolean"})
    add_configs("vp9-highbitdepth", {description = "use VP9 high bit depth (10/12) profiles", default = false, type = "boolean"})

    if is_plat("wasm") then
        add_configs("shared",  {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_host("freebsd", "linux", "macosx") then
        add_deps("which")
    end

    -- array utils
    function filter(array, filter)
      local result = {}
      for idx, val in ipairs(array) do
          if filter(val, idx, array) then
            table.insert(result, val)
          end
      end
      return result
    end

    function find(array, filter)
      for idx, val in ipairs(array) do
          if filter(val, idx, array) then
              return val
          end
      end
      return nil
    end

    function get_target(package)
        import("core.tool.compiler")
        local default_plat = "generic-gnu"

        local platforms = {}
        for plat in io.readfile("configure"):gmatch("all_platforms=\"%${all_platforms} ([%a%d-]-)\"") do
            table.insert(targets, plat:split("-", {plain = true}))
        end

        local arch = package:targetarch()
        if arch:startswith("arm64") then
            arch = "arm64"
        elseif arch == "armeabi-v7a" then
            arch = "armv7"
        elseif arch == "x64" then
            arch = "x86_64"
        end

        local os
        if package:is_targetos("iphoneos") then
            if package:is_targetarch("x64", "x86", "x86_64") then
                os = "iphonesimulator"
            else
                os = "darwin"
            end
        elseif package:is_targetos("macosx", "watchos") then
            os = "darwin"
        elseif package:is_targetos("cygwin", "mingw", "windows") then
            os = "win"
        else
            os = package:targetos()
        end

        local cc = path.basename(compiler.compcmd("foo.c")):split(" ", {plain = true})[1]:lower()
        if cc == "clang" or cc == "emcc" then
            cc = "gcc"
        elseif cc == "cl" then
            cc = "vs"
        end

        local matched_plats
        matched_plats = filter(platforms, function (p) return p[1] == arch end)
        local tmp = filter(matched_plats, function (p) return p[2] == os end)
        matched_plats = #tmp == 0 and filter(matched_plats, function (p) return p[2]:startswith(plat) end) or tmp
        tmp = nil
        if #matched_plats == 0 then
            cprint("${yellow}warning: ${clear}no matching platform for " .. os .. "-" .. arch " " .. cc .. ", use " .. default_plat)
        end
        local result = find(platforms, function(p) return p[3] == cc end) or find(platforms, function(p) return p[3]:startswith(cc) end) or platforms[1]
        cprint("${green}info: ${clear}use target platform ${blue}" .. result .. "${clear}")
        return result
    end

    on_load(function (package)
        if package:is_targetarch("x64", "x86_64") then
            if package:is_plat("freebsd") then
                package:add("deps", "nasm")
            else
                package:add("deps", "yasm")
            end
        end
    end)

    on_install("@bsd", "@linux", "@macosx", "mingw", "wasm", function (package)
        local configs = {}
        table.insert(configs, "--prefix=" .. package:installdir())
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "--" .. (enabled and "enable" or "disable") .. "-" .. name)
            end
        end

        if package:is_plat("wasm") then
            table.join2(configs, {"--target=generic-gnu", "--disable-install-bins"})
        elseif package:is_cross() then
            table.insert(configs, "--target=" .. get_target(package))
        end

        local source_dir = os.curdir()
        os.cd("$(buildir)")
        if package:is_plat("wasm") then
            os.vrunv("emconfigure " .. path.join(source_dir, "/configure"), configs)
        else
            os.vrunv(path.join(source_dir, "configure"), configs)
        end
        import("package.tools.make").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vpx_codec_enc_init_ver", {includes = "vpx/vpx_encoder.h"}))
    end)
