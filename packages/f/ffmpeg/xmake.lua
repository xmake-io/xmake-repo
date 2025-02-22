package("ffmpeg")
    set_homepage("https://www.ffmpeg.org")
    set_description("A collection of libraries to process multimedia content such as audio, video, subtitles and related metadata.")
    set_license("GPL-3.0")

    add_urls("https://ffmpeg.org/releases/ffmpeg-$(version).tar.bz2", {alias = "home"})
    add_urls("https://github.com/FFmpeg/FFmpeg/archive/n$(version).zip", {alias = "github"})
    add_urls("https://git.ffmpeg.org/ffmpeg.git", "https://github.com/FFmpeg/FFmpeg.git", {alias = "git"})

    add_versions("home:7.1", "fd59e6160476095082e94150ada5a6032d7dcc282fe38ce682a00c18e7820528")
    add_versions("home:7.0", "a24d9074bf5523a65aaa9e7bd02afe4109ce79d69bd77d104fed3dab4b934d7a")
    add_versions("home:6.1", "eb7da3de7dd3ce48a9946ab447a7346bd11a3a85e6efb8f2c2ce637e7f547611")
    add_versions("home:6.0.1", "2c6e294569d1ba8e99cbf1acbe49e060a23454228a540a0f45d679d72ec69a06")
    add_versions("home:5.1.2", "39a0bcc8d98549f16c570624678246a6ac736c066cebdb409f9502e915b22f2b")
    add_versions("home:5.1.1", "cd0e16f903421266d5ccddedf7b83b9e5754aef4b9f7a7f06ce9e4c802f0545b")
    add_versions("home:5.0.1", "28df33d400a1c1c1b20d07a99197809a3b88ef765f5f07dc1ff067fac64c59d6")
    add_versions("home:4.4.4", "47b1fbf70a2c090d9c0fae5910da11c6406ca92408bb69d8c935cd46c622c7ce")
    add_versions("home:4.0.2", "346c51735f42c37e0712e0b3d2f6476c86ac15863e4445d9e823fe396420d056")
    add_versions("github:7.1", "201fe5427412e0a0a0304a545f2aceb7e95e2ef1c26a7e486d3106fd156ed812")
    add_versions("github:7.0", "9ea4f1e934b1655c9a6dad579fd52fa299cd4f6a5f2b82be97daa98ff2e798d0")
    add_versions("github:6.1", "7da07ff7e30bca95c0593db20442becba13ec446dd9c3331ca3d1b40eecd3c93")
    add_versions("github:6.0.1", "2acb5738a1b4b262633ac2d646340403ae47120d9eb289ecad23fc90093c0d6c")
    add_versions("github:5.1.2", "0c99f3609160f40946e2531804175eea16416320c4b6365ad075e390600539db")
    add_versions("github:5.1.1", "a886fcc94792764c27c88ebe71dffbe5f0d37df8f06f01efac4833ac080c11bf")
    add_versions("github:5.0.1", "f9c2e06cafa4381df8d5c9c9e14d85d9afcbc10c516c6a206f821997cc7f6440")
    add_versions("github:4.4.4", "b0d16b48bd8ccb160e14291145294b0b12597e32b17175f7604288a8c73216de")
    add_versions("github:4.0.2", "4df1ef0bf73b7148caea1270539ef7bd06607e0ea8aa2fbf1bb34062a097f026")
    add_versions("git:7.1", "n7.1")
    add_versions("git:7.0", "n7.0")
    add_versions("git:6.1", "n6.1")
    add_versions("git:6.0.1", "n6.0.1")
    add_versions("git:5.1.2", "n5.1.2")
    add_versions("git:5.1.1", "n5.1.1")
    add_versions("git:5.0.1", "n5.0.1")
    add_versions("git:4.0.2", "n4.0.2")

    add_configs("gpl",              {description = "Enable GPL code", default = true, type = "boolean"})
    add_configs("ffprobe",          {description = "Enable ffprobe program.", default = false, type = "boolean"})
    add_configs("ffmpeg",           {description = "Enable ffmpeg program.", default = true, type = "boolean"})
    add_configs("ffplay",           {description = "Enable ffplay program.", default = false, type = "boolean"})
    add_configs("zlib",             {description = "Enable zlib compression library.", default = false, type = "boolean"})
    add_configs("lzma",             {description = "Enable liblzma compression library.", default = false, type = "boolean"})
    add_configs("bzlib",            {description = "Enable bzlib compression library.", default = false, type = "boolean"})
    add_configs("libx264",          {description = "Enable libx264 encoder.", default = false, type = "boolean"})
    add_configs("libx265",          {description = "Enable libx265 encoder.", default = false, type = "boolean"})
    add_configs("iconv",            {description = "Enable libiconv library.", default = false, type = "boolean"})
    add_configs("vaapi",            {description = "Enable vaapi library.", default = false, type = "boolean"})
    add_configs("vdpau",            {description = "Enable vdpau library.", default = false, type = "boolean"})
    add_configs("hardcoded-tables", {description = "Enable hardcoded tables.", default = true, type = "boolean"})
    if is_plat("linux") then
        add_configs("libdrm", {description = "Enable libdrm hardware acceleration", default = true, type = "boolean"})
    end

    add_links("avfilter", "avdevice", "avformat", "avcodec", "swscale", "swresample", "avutil", "postproc")
    if is_plat("macosx", "iphoneos") then
        add_frameworks("CoreFoundation", "Foundation", "CoreVideo", "CoreMedia", "VideoToolbox", "Security")
        if is_plat("iphoneos") then
            add_frameworks("AVFoundation")
        else
            add_frameworks("AudioToolbox")
        end
    elseif is_plat("linux") then
        add_syslinks("dl", "pthread")
    elseif is_plat("android") then
        add_syslinks("dl", "android", "mediandk")
    end

    add_deps("nasm")
    if is_plat("linux", "macosx") then
        add_deps("pkg-config")
    end

    on_fetch("mingw", "linux", "macosx", function (package, opt)
        import("lib.detect.find_tool")
        if opt.system then
            local result
            for _, name in ipairs({"libavcodec", "libavdevice", "libavfilter", "libavformat", "libavutil", "libpostproc", "libswresample", "libswscale"}) do
                local pkginfo = package:find_package("pkgconfig::" .. name, opt)
                if pkginfo then
                    pkginfo.version = nil
                    if not result then
                        result = pkginfo
                    else
                        result = result .. pkginfo
                    end
                else
                    return
                end
            end
            local ffmpeg = find_tool("ffmpeg", {check = "-help", version = true, command = "-version", parse = "%d+%.?%d+%.?%d+", force = true})
            if ffmpeg then
                result.version = ffmpeg.version
            end
            return result
        end
    end)

    on_load(function (package)
        local configdeps = {zlib    = "zlib",
                            bzlib   = "bzip2",
                            lzma    = "xz",
                            libx264 = "x264",
                            libx265 = "x265",
                            iconv   = "libiconv",
                            libdrm  = "libdrm"}
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
        -- https://www.ffmpeg.org/platform.html#toc-Advanced-linking-configuration
        if package:config("pic") ~= false and package:is_plat("linux", "android") then
            package:add("shflags", "-Wl,-Bsymbolic")
            package:add("ldflags", "-Wl,-Bsymbolic")
        end
        if not package:config("gpl") then
            package:set("license", "LGPL-3.0")
        end
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("syslinks", "Bcrypt", "Mfplat", "mfuuid", "Ole32", "Secur32", "Strmiids", "User32", "ws2_32")
        end
        if is_subhost("windows") and os.arch() == "x64" then
            local configs = {
                msystem = "MINGW64",
                base_devel = true,
            }
            -- @see https://stackoverflow.com/questions/65438878/ffmpeg-build-on-windows-using-msvc-make-fails
            configs.make = true
            if not package:is_plat("windows", "mingw") then
                configs.mingw64_gcc = true
            end
            package:add("deps", "msys2", {configs = configs})
        end

        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
    end)

    on_install("windows", "mingw@windows,linux,cygwin,msys", "linux", "macosx", "android", "iphoneos", function (package)
        local configs = {"--enable-version3",
                         "--disable-doc"}
        configs.host = "" -- prevents xmake to add a --host=xx parameter (unsupported by ffmpeg configure script)
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    table.insert(configs, "--enable-" .. name)
                else
                    table.insert(configs, "--disable-" .. name)
                end
            end
        end
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")
        else
            table.insert(configs, "--enable-static")
            table.insert(configs, "--disable-shared")
        end
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end

        if package:is_plat("windows") then
            table.insert(configs, "--target-os=win32")
            table.insert(configs, "--enable-w32threads")
            table.insert(configs, "--enable-d3d11va")
            table.insert(configs, "--enable-dxva2")
            table.insert(configs, "--enable-mediafoundation")
            table.insert(configs, "--toolchain=msvc")
            table.insert(configs, "--extra-cflags=-" .. package:runtimes())
        elseif package:is_plat("mingw") then
            if package:is_arch("x86", "i386", "i686") then
                table.insert(configs, "--target-os=mingw32")
            elseif package:is_arch("x86_64") then
                table.insert(configs, "--target-os=mingw64")
            else
                raise("unknown mingw arch " .. package:arch())
            end
        elseif package:is_plat("linux") then
            table.insert(configs, "--target-os=linux")
            table.insert(configs, "--enable-pthreads")
        elseif package:is_plat("macosx", "iphoneos") then
            table.insert(configs, "--target-os=darwin")
            if package:is_plat("macosx") then
                table.insert(configs, "--enable-appkit")
                table.insert(configs, "--enable-audiotoolbox")
            else
                 -- ffmpeg does not support audiotoolbox on iOS: https://github.com/kewlbear/FFmpeg-iOS-build-script/issues/158
                table.insert(configs, "--disable-audiotoolbox")
            end
            if macos.version():ge("10.7") then
                table.insert(configs, "--enable-avfoundation")
            end
            if macos.version():ge("10.8") then
                table.insert(configs, "--enable-videotoolbox")
            end
            if macos.version():ge("10.11") then
                table.insert(configs, "--enable-coreimage")
            end
        elseif package:is_plat("android") then
            table.insert(configs, "--target-os=android")
            table.insert(configs, "--enable-neon")
            table.insert(configs, "--enable-asm")
            table.insert(configs, "--enable-jni")
            table.insert(configs, "--enable-mediacodec")
        else
            raise("unexpected platform")
        end

        if package:is_cross() then
            table.insert(configs, "--enable-cross-compile")
            local arch = package:targetarch()
            if arch:match("arm64.*") then
                arch = "arm64"
            end
            table.insert(configs, "--arch=" .. arch)
        end

        if package:is_plat("windows") then
            if path.cygwin then -- xmake 2.8.9
                import("package.tools.autoconf")
                local envs = autoconf.buildenvs(package, {packagedeps = "libiconv"})
                if not envs.PATH then -- Fix in xmake 2.9.8
                    local msvc = package:toolchain("msvc") or toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
                    envs.PATH = os.getenv("PATH") -- we need to reserve PATH on msys2
                    envs = os.joinenvs(envs, msvc:runenvs())
                end
                if package:config("shared") and package:is_cross() then
                    -- The makedef script always assumes that the AR environment variable is gnu ar
                    -- @see https://github.com/microsoft/vcpkg/issues/42365#issuecomment-2567009409
                    envs.AR = nil
                end
                -- add gas-preprocessor to PATH
                if package:is_arch("arm", "arm64") then
                    envs.PATH = path.join(os.programdir(), "scripts") .. path.envsep() .. envs.PATH
                end
                autoconf.install(package, configs, {envs = envs})
            else
                import("core.base.option")
                import("core.tool.toolchain")
                local msvc = package:toolchain("msvc") or toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
                assert(msvc:check(), "vs not found!")
                local buildenvs = import("package.tools.autoconf").buildenvs(package)
                -- keep msys2 envs in front to prevent conflict with possibly installed sh.exe
                local envs = os.joinenvs(os.getenvs(), msvc:runenvs())
                -- fix PKG_CONFIG_PATH for checking deps, e.g. x264, x265 ..
                -- @see https://github.com/xmake-io/xmake-repo/issues/3442
                local pkg_config_path = buildenvs.PKG_CONFIG_PATH
                if pkg_config_path then
                    local paths = {}
                    for _, p in ipairs(path.splitenv(pkg_config_path)) do
                        p = p:gsub("\\", "/")
                        -- c:\, C:\ -> /c/
                        p = p:gsub("^(%w):", function (drive) return "/" .. drive:lower() end)
                        table.insert(paths, p)
                    end
                    envs.PKG_CONFIG_PATH = table.concat(paths, ":")
                end
                envs.SHELL = "sh"

                -- add gas-preprocessor to PATH
                if package:is_arch("arm", "arm64") then
                    envs.PATH = path.join(os.programdir(), "scripts") .. path.envsep() .. envs.PATH
                end

                table.insert(configs, "--prefix=" .. package:installdir():gsub("\\", "/"))
                os.vrunv("./configure", configs, {shell = true, envs = envs})

                local njob = option.get("jobs") or tostring(os.default_njob())
                local argv = {"-j" .. njob}
                if option.get("verbose") then
                    table.insert(argv, "V=1")
                end
                os.vrunv("make", argv, {envs = envs})
                os.vrunv("make", {"install"}, {envs = envs})
            end
            if package:config("shared") then
                -- move .lib from bin/ to lib/
                os.vmv(package:installdir("bin", "*.lib"), package:installdir("lib"))
            else
                -- rename files from libxx.a to xx.lib
                for _, libfile in ipairs(os.files(package:installdir("lib", "*.a"))) do
                    os.vmv(libfile, (libfile:gsub("^(.+[\\/])lib(.+)%.a$", "%1%2.lib")))
                end
            end
        elseif package:is_plat("android") then
            import("core.base.option")
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local bin = ndk:bindir()
            local ndk_sdkver = ndk:config("ndk_sdkver")
            local arch, cpu, triple, cross_prefix
            if package:is_arch("arm64-v8a") then
                arch = "arm64"
                cpu = "armv8-a"
                triple = "aarch64-linux-android"
                cross_prefix = path.join(bin, "aarch64-linux-android-")
            elseif package:arch():startswith("arm") then
                arch = "arm"
                cpu = "armv7-a"
                triple = "armv7a-linux-androideabi"
                cross_prefix = path.join(bin, "arm-linux-androideabi-")
            elseif package:is_arch("x86") then
                arch = "x86_android"
                cpu = "x86"
                triple = "i686-linux-android"
                cross_prefix = path.join(bin, "i686-linux-android-")
             elseif package:is_arch("x86_64") then
                arch = "x86_64_android"
                cpu = "x86_64"
                triple = "x86_64-linux-android"
                cross_prefix = path.join(bin, "x86_64-linux-android-")
            else
                raise("unknown arch(%s) for android!", package:arch())
            end
            local _translate_path
            if is_host("windows") then
                _translate_path = function (p) return p and p:gsub("\\", "/") or p end
            else
                _translate_path = function (p) return p end
            end
            local sysroot  = path.join(path.directory(bin), "sysroot")
            local cflags   = table.join(table.wrap(package:config("cxflags")), table.wrap(package:config("cflags")), table.wrap(get_config("cxflags")), get_config("cflags"))
            local cxxflags = table.join(table.wrap(package:config("cxflags")), table.wrap(package:config("cxxflags")), table.wrap(get_config("cxflags")), get_config("cxxflags"))
            assert(os.isdir(sysroot), "we do not support old version ndk!")

            local ndkver = tonumber(ndk:config("ndkver"))
            if package:is_arch("arm64-v8a") then
                -- https://github.com/llvm/llvm-project/issues/74361
                if ndkver < 27 then
                    table.insert(cflags, "-mfpu=neon")
                    table.insert(cflags, "-mfloat-abi=hard")
                end
            else
                table.insert(cflags, "-mfpu=neon")
                table.insert(cflags, "-mfloat-abi=soft")
            end
            table.insert(configs, "--disable-avdevice")
            table.insert(configs, "--arch=" .. arch)
            table.insert(configs, "--cpu=" .. cpu)
            table.insert(configs, "--cc=" .. _translate_path(path.join(bin, triple .. ndk_sdkver .. "-clang")))
            table.insert(configs, "--cxx=" .. _translate_path(path.join(bin, triple .. ndk_sdkver .. "-clang++")))
            table.insert(configs, "--ar=" .. _translate_path(path.join(bin, "llvm-ar")))
            table.insert(configs, "--ranlib=" .. _translate_path(path.join(bin, "llvm-ranlib")))
            table.insert(configs, "--strip=" .. _translate_path(path.join(bin, "llvm-strip")))
            table.insert(configs, "--extra-cflags=" .. table.concat(cflags, ' '))
            table.insert(configs, "--extra-cxxflags=" .. table.concat(cxxflags, ' '))
            table.insert(configs, "--sysroot=" .. _translate_path(sysroot))
            table.insert(configs, "--cross-prefix=" .. _translate_path(cross_prefix))
            table.insert(configs, "--prefix=" .. _translate_path(package:installdir()))
            os.vrunv("./configure", configs, {shell = true})
            local njob = option.get("jobs") or tostring(os.default_njob())
            local argv = {"-j" .. njob}
            if option.get("verbose") or is_subhost("windows") then -- we always need enable it on windows, otherwise it will fail.
                table.insert(argv, "V=1")
            end
            os.vrunv("make", argv)
            os.vrun("make install")
        else
            local opt
            if package:is_plat("macosx") and package:is_arch("arm.*") and package:config("shared") then
                opt = {}
                -- https://github.com/spack/spack/issues/40159
                opt.shflags = "-Wl,-ld_classic"
            end
            import("package.tools.autoconf").install(package, configs, opt)
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            for _, tool in ipairs({"ffprobe", "ffmpeg", "ffplay"}) do
                if package:config(tool) then
                    os.vrunv(tool, {"-version"})
                end
            end
        end

        if package:is_library() then
            assert(package:has_cfuncs("avformat_open_input", {includes = "libavformat/avformat.h"}))
        end
    end)
