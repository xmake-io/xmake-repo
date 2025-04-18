package("freerdp")
    set_homepage("http://www.freerdp.com")
    set_description("FreeRDP is a free remote desktop protocol library and clients ")
    set_license("Apache-2.0")

    add_urls("https://github.com/FreeRDP/FreeRDP/releases/download/$(version)/freerdp-$(version).tar.gz",
             "https://github.com/FreeRDP/FreeRDP.git")

    add_versions("3.15.0", "e8cd58decef4c970faea2fbea675970eea60e440ebe8033c54889acb83787371")

    add_configs("client", {description = "Build client", default = false, type = "boolean"})
    add_configs("server", {description = "Build server", default = false, type = "boolean"})
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

    -- winpr
    add_configs("unicode_builtin", {description = "Build builtin unicode", default = true, type = "boolean"})
    add_configs("timezone_icu", {description = "Use ICU for improved timezone mapping", default = false, type = "boolean"})
    add_configs("winpr_tools", {description = "Build WinPR helper binaries", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_configs("winmm", {description = "Use Windows Multimedia", default = true, type = "boolean"})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("zlib", "openssl", "libusb")

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
            x11       = "libx11",
            shadow    = "libx11",
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

        if not package:config("unicode_builtin") or package:config("timezone_icu") then
            package:add("deps", "icu4c")
        end

        if package:config("winmm") and package:is_plat("windows", "mingw") then
            package:add("syslinks", "winmm")
        end

        -- TODO: patch libusb dep(udev)
        if package:config("client") and package:is_plat("linux") then
            package:add("deps", "libusb", {configs = {shared = true}})
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "include(${CMAKE_CPACK_INCLUDE_FILE})", "", {plain = true})

        local configs = {
            "-DWITH_SAMPLE=OFF",
            "-DBUILD_TESTING=OFF",
            "-DWITH_CCACHE=OFF",
            "-DWITH_CLANG_FORMAT=OFF",

            "-DFREERDP_UNIFIED_BUILD=ON",

            "-DWITH_CUPS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local dep = package:config("json")
        table.insert(configs, "-DWITH_JSON_DISABLED=" .. (dep and "OFF" or "ON"))
        table.insert(configs, "-DWITH_CJSON_REQUIRED=" .. (dep == "cjson" and "ON" or "OFF"))
        table.insert(configs, "-DWITH_JSONC_REQUIRED=" .. (dep == "json-c" and "ON" or "OFF"))

        table.insert(configs, "-DWITH_CLIENT_COMMON=" .. (package:config("client") and "ON" or "OFF"))

        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, format("-DWITH_%s=%s", name:upper(), (enabled and "ON" or "OFF")))
            end
        end

        local opt = {}
        if package:dep("ffmpeg") and not package:has_tool("ld", "link") then
            -- https://stackoverflow.com/questions/44379426/building-shared-library-with-ffmpeg-results-in-relocation-error
            opt.ldflags = "-Wl,-Bsymbolic"
            opt.shflags = "-Wl,-Bsymbolic"
        end

        import("package.tools.cmake").install(package, configs, opt)

        if package:is_plat("windows") and not package:config("shared") then
            io.replace(path.join(package:installdir("include"), "freerdp/api.h"), "__declspec(dllimport)", "", {plain = true})
            io.replace(path.join(package:installdir("include"), "winpr/platform.h"), "__declspec(dllimport)", "", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("winpr_get_version", {includes = "winpr/winpr.h"}))
        assert(package:has_cfuncs("freerdp_get_version", {includes = "freerdp/freerdp.h"}))
    end)
