package("msquic")
    set_homepage("https://github.com/microsoft/msquic")
    set_description("Cross-platform, C implementation of the IETF QUIC protocol.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/msquic.git")
    add_versions("v1.9.0", "v1.9.0")

    add_deps("cmake")
    add_includedirs("msquic/include")

    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "Security")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl", "m")
    end

    on_load(function (package)
        if package:config("shared") then
            package:add("links", "msquic")
        else
            package:add("links", "msquic_static")
        end
        package:add("links", "core", "platform", "ssl", "crypto")
    end)

    on_install("linux", "macosx", function (package)
        local configs = {"-DQUIC_BUILD_TOOLS=OFF",
                         "-DQUIC_BUILD_TEST=OFF",
                         "-DQUIC_BUILD_PERF=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        if package:debug() then
            os.cp("build/*/Debug/*", package:installdir("lib"))
        else
            os.cp("build/*/Release/*", package:installdir("lib"))
        end
        os.cp("build/*/*/openssl/lib/*", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("MsQuicOpenVersion", {includes = "msquic.h"}))
    end)
