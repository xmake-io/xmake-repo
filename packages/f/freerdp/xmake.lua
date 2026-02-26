package("freerdp")
    set_homepage("https://www.freerdp.com/")
    set_description("FreeRDP is a free remote desktop protocol library and clients ")
    set_license("Apache-2.0")

    add_urls("https://github.com/FreeRDP/FreeRDP/releases/download/$(version)/freerdp-$(version).tar.gz",
             "https://github.com/FreeRDP/FreeRDP.git")

    add_versions("3.22.0", "656670f3aac2c995cb4b1ba181549cc122cc9c95ec31be68a582c1182f474376")
    add_versions("3.21.0", "ec1409ce88020eeebc54e20cc0766cbe7d2e2f4bd382c7061c86f89231a9f44d")
    add_versions("3.20.0", "96631873b00c8a872c9fe4e668957c3e4e0808f81ccb71f6ac028096a2682806")
    add_versions("3.19.1", "0886818968884464d72f8c363b633e97561bd438d84fce7331cb0df07b088919")
    add_versions("3.18.0", "70e89fdc92e3c2a429a7e61015ffd55bda4f6fefd76bb2978a91134d94869462")
    add_versions("3.17.2", "c42c712ad879bf06607b78b8c3fad98e08c82f73f4e0bc1693552900041e692a")
    add_versions("3.16.0", "385af54245560493698730b688b5e6e5d56d5c7ecf2fa7c1d7cedfde8a4ba456")
    add_versions("3.15.0", "e8cd58decef4c970faea2fbea675970eea60e440ebe8033c54889acb83787371")

    if is_plat("mingw") then
        add_patches(">=3.19.1", "patches/3.19.1/mingw-c11.patch", "84083315e41f8e2800c838ef9d36a7db3ea6470ae86c30ed691af30a017b5870")
    end

    add_configs("client", {description = "Build client", default = false, type = "boolean"})
    add_configs("client_channels", {description = "Build virtual channel plugins", default = false, type = "boolean"})
    add_configs("server", {description = "Build server", default = false, type = "boolean"})
    add_configs("server_channels", {description = "Build virtual channel plugins", default = false, type = "boolean"})
    add_configs("rdtk", {description = "Build rdtk toolkit", default = false, type = "boolean"})
    add_configs("shadow", {description = "Compile with shadow server", default = false, type = "boolean"})
    add_configs("proxy", {description = "Compile with proxy server", default = false, type = "boolean"})
    add_configs("platform_server", {description = "Compile with platform server", default = false, type = "boolean"})

    add_configs("x11", {description = "Build X11 client/server", default = false, type = "boolean"})
    add_configs("wayland", {description = "Build with wayland", default = false, type = "boolean"})
    add_configs("fuse", {description = "Build clipboard with FUSE file copy support", default = false, type = "boolean"})
    add_configs("json", {description = "Build with any JSON support", default = nil, type = "string", values = {"cjson", "json-c"}})
    add_configs("uriparser", {description = "use uriparser library to handle URIs", default = false, type = "boolean"})
    add_configs("ffmpeg", {description = "Enable FFMPEG for audio/video encoding/decoding", default = false, type = "boolean"})
    add_configs("cairo", {description = "Use CAIRO image library for screen resizing", default = false, type = "boolean"})
    add_configs("swscale", {description = "Use SWScale image library for screen resizing", default = false, type = "boolean"})
    add_configs("openh264", {description = "Build openh264", default = false, type = "boolean"})
    add_configs("krb5", {description = "Compile support for kerberos authentication.", default = false, type = "boolean"})
    -- Try resolve emmintrin.h:740:1: error: inlining failed in call to 'always_inline' '_mm_storeu_si128': target specific option mismatch
    add_configs("simd", {description = "Build with simd", default = not is_plat("wasm") and not (is_arch("i386") and is_plat("mingw") and is_subhost("macosx")), type = "boolean"})

    -- winpr
    add_configs("unicode_builtin", {description = "Build builtin unicode", default = true, type = "boolean"})
    add_configs("timezone_icu", {description = "Use ICU for improved timezone mapping", default = false, type = "boolean"})
    add_configs("winpr_tools", {description = "Build WinPR helper binaries", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_configs("winmm", {description = "Use Windows Multimedia", default = true, type = "boolean"})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("rpcrt4", "ncrypt", "shell32", "ole32", "dbghelp", "shlwapi", "ntdll")
        if is_plat("mingw") then
            add_syslinks("uuid")
        end
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "Carbon")
    end

    add_deps("cmake")
    add_deps("zlib", "openssl3")

    add_includedirs("include", "include/freerdp3", "include/winpr3")

    add_links("freerdp-server3", "freerdp-server-proxy3", "freerdp-client3", "freerdp3", "rdtk0", "winpr3")

    on_load(function (package)
        if package:config("shadow") or package:config("proxy") or package:config("platform_server") then
            package:config_set("server", true)
        end
        if package:config("proxy") then
            package:config_set("client", true)
        end

        local configs_map_to_deps = {
            client    = "libusb",
            wayland   = "wayland",
            fuse      = "libfuse",
            json      = package:config("json"),
            uriparser = "uriparser",
            cairo     = "cairo",
            openh264  = "openh264",
            ffmpeg    = "ffmpeg",
            swscale   = "ffmpeg",
            krb5      = "krb5",
        }
        for config, dep in pairs(configs_map_to_deps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end

        if package:config("x11") or package:config("shadow") then
            package:add("deps", "libx11", "libxext", "libxcursor")
        end
        if not package:config("unicode_builtin") or package:config("timezone_icu") then
            package:add("deps", "icu4c")
        end

        if package:dep("libusb") then
            if is_subhost("windows") then
                package:add("deps", "pkgconf")
            else
                package:add("deps", "pkg-config")
            end
        end

        -- https://github.com/libfuse/libfuse/issues/383
        if package:config("fuse") then
            package:add("deps", "libfuse", {configs = {shared = true}})
        end

        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "FREERDP_EXPORTS")
        end

        if package:config("winmm") and package:is_plat("windows", "mingw") then
            package:add("syslinks", "winmm")
        end
    end)

    on_install("!bsd and !iphoneos", function (package)
        if package:is_plat("mingw") then
            io.replace("winpr/include/winpr/wtypes.h", "typedef ssize_t SSIZE_T;", "#ifndef _SSIZE_T_DEFINED\ntypedef ssize_t SSIZE_T;\n#endif", {plain = true})
        end
        io.replace("CMakeLists.txt", "include(${CMAKE_CPACK_INCLUDE_FILE})", "", {plain = true})
        io.replace("cmake/MSVCRuntime.cmake", "if(BUILD_SHARED_LIBS)", "if(0)", {plain = true})
        if package:config("fuse") then
            io.replace("client/common/CMakeLists.txt", "pkg_check_modules(FUSE3 REQUIRED fuse3)", "pkg_check_modules(FUSE3 REQUIRED IMPORTED_TARGET fuse3)", {plain = true})
            io.replace("client/common/CMakeLists.txt", "${FUSE3_LIBRARIES}", "PkgConfig::FUSE3", {plain = true})
        end

        local libusb = package:dep("libusb")
        if libusb and not libusb:is_system() and not libusb:config("shared") and package:is_plat("linux", "cross") then
            io.replace("cmake/Findlibusb-1.0.cmake", "set(LIBUSB_1_LIBRARIES ${LIBUSB_1_LIBRARY})",
                [[find_package(PkgConfig)
                  pkg_check_modules(PC_LIBUDEV QUIET libudev)
                  find_library(UDEV_LIBRARY NAMES udev PATHS ${PC_LIBUDEV_LIBRARY_DIRS} ${PC_LIBUDEV_LIBDIR} PATH_SUFFIXES lib)
                  set(LIBUSB_1_LIBRARIES ${LIBUSB_1_LIBRARY} ${UDEV_LIBRARY})]], {plain = true})
        end

        local configs = {
            "-DWITH_SAMPLE=OFF",
            "-DWITH_MANPAGES=OFF",
            "-DBUILD_TESTING=OFF",
            "-DWITH_CCACHE=OFF",
            "-DWITH_CLANG_FORMAT=OFF",
            "-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF",
            -- build bundle winpr
            "-DFREERDP_UNIFIED_BUILD=ON",

            "-DWITH_CUPS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local dep = package:config("json")
        table.insert(configs, "-DWITH_JSON_DISABLED=" .. (dep and "OFF" or "ON"))
        table.insert(configs, "-DWITH_CJSON_REQUIRED=" .. (dep == "cjson" and "ON" or "OFF"))
        table.insert(configs, "-DWITH_JSONC_REQUIRED=" .. (dep == "json-c" and "ON" or "OFF"))
        if package:is_plat("mingw") then
            -- winpr/libwinpr/utils/unwind/debug.c require dlfcn.h, try `dlfcn-win32`?
            table.insert(configs, "-DUSE_UNWIND=OFF")
            -- fatal error: bits/libc-header-start.h: No such file or directory
            table.insert(configs, "-DWITH_SMARTCARD_EMULATE=OFF")
        end

        table.insert(configs, "-DWITH_CLIENT_COMMON=" .. (package:config("client") and "ON" or "OFF"))

        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, format("-DWITH_%s=%s", name:upper(), (enabled and "ON" or "OFF")))
            end
        end

        local opt = {}
        if package:is_plat("mingw") and package:has_tool("cc", "gcc") then
            opt.cxflags = "-Wno-error=incompatible-pointer-types"
        end
        if package:dep("libx11") then
            opt.packagedeps = {"libx11", "xorgproto", "libxext", "libxcursor"}
        end
        if package:dep("ffmpeg") and not package:has_tool("ld", "link") then
            -- https://stackoverflow.com/questions/44379426/building-shared-library-with-ffmpeg-results-in-relocation-error
            opt.ldflags = "-Wl,-Bsymbolic"
            opt.shflags = "-Wl,-Bsymbolic"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("winpr_get_version", {includes = "winpr/winpr.h"}))
        assert(package:has_cfuncs("freerdp_get_version", {includes = "freerdp/freerdp.h"}))
    end)
