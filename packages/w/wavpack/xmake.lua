package("wavpack")
    set_homepage("https://github.com/dbry/WavPack")
    set_description("WavPack encode/decode library, command-line programs, and several plugins")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/dbry/WavPack//archive/refs/tags/$(version).tar.gz",
             "https://github.com/dbry/WavPack.git")

    add_versions("5.9.0", "2a53e50aefd8c9f04a0828a0e1ef77b6f4c17b0ef6964ad234ab295f313b7d6d")
    add_versions("5.8.1", "1228dda992cf70ddda278d0a7ead410cfa8ea7f29ba23da7c6fdcbefb74ca363")
    add_versions("5.7.0", "c5742ba1054d36ff3d22f0101a9be066f55f6becb9b2a7352c79fa362f2d3d76")
    add_versions("5.6.0",  "44043e8ffe415548d5723e9f4fc6bda5e1f429189491c5fb3df08b8dcf28df72")
    add_versions("5.5.0",  "b3d11ba35d12c7d2ed143036478b6f9f4bdac993d84b5ed92615bc6b60697b8a")
    add_versions("5.4.0",  "abbe5ca3fc918fdd64ef216200a5c896243ea803a059a0662cd362d0fa827cd2")
    add_versions("4.80.0", "c72cb0bbe6490b84881d61f326611487eedb570d8d2e74f073359578b08322e2")

    add_configs("legacy",  {description = "Decode legacy (< 4.0) WavPack files", default = false, type = "boolean"})
    add_configs("threads", {description = "Enable support for threading in libwavpack", default = true, type = "boolean"})
    add_configs("dsd",     {description = "Enable support for WavPack DSD files", default = true, type = "boolean"})

    add_deps("cmake")
    if not is_plat("windows") then
        add_deps("libiconv", "openssl", {optional = true})
    end

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install("windows", "linux", "bsd", "macosx", "mingw", "android", "wasm", function (package)
        if package:is_plat("android") and package:is_arch("armeabi-v7a") then
            import("core.tool.toolchain")
            local ndk = toolchain.load("ndk", {plat = package:plat(), arch = package:arch()})
            local ndk_sdkver = ndk:config("ndk_sdkver")
            if tonumber(ndk_sdkver) < 24 then
                -- cross compilation check failure, remove it
                io.replace("CMakeLists.txt", "$<$<BOOL:${HAVE_FSEEKO}>:HAVE_FSEEKO>", "", {plain = true})
            end
        end

        local configs = {
            "-DWAVPACK_BUILD_PROGRAMS=OFF",
            "-DWAVPACK_INSTALL_CMAKE_MODULE=OFF",
            "-DWAVPACK_INSTALL_DOCS=OFF",
            "-DWAVPACK_INSTALL_PKGCONFIG_MODULE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DWAVPACK_ENABLE_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end

        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") then
            os.trycp(path.join(package:installdir("lib"), "libwavpack.a"),
                path.join(package:installdir("lib"), "libwavpack.lib"))
            os.trycp(path.join(package:installdir("lib"), "libwavpack.dll.a"),
                path.join(package:installdir("lib"), "libwavpack.lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("WavpackOpenRawDecoder", {includes = "wavpack/wavpack.h"}))
    end)
