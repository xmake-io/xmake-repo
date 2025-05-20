package("usrsctp")
    set_homepage("https://github.com/sctplab/usrsctp")
    set_description("A portable SCTP userland stack")

    add_urls("https://github.com/sctplab/usrsctp/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%+", ".")
    end})
    add_urls("https://github.com/sctplab/usrsctp.git")

    add_versions("0.9.5+0", "260107caf318650a57a8caa593550e39bca6943e93f970c80d6c17e59d62cd92")
    
    add_configs("invariants", {description = "Add runtime checks", default = false, type = "boolean"})
    add_configs("inet", {description = "Support IPv4", default = true, type = "boolean"})
    add_configs("inet6", {description = "Support IPv6", default = true, type = "boolean"})
    add_configs("werror", {description = "Treat warning as error", default = false, type = "boolean"})
    add_configs("sanitizer_address", {description = "Compile with address sanitizer", default = false, type = "boolean"})
    add_configs("sanitizer_memory", {description = "Compile with memory sanitizer", default = false, type = "boolean"})
    add_configs("build_fuzzer", {description = "Compile in clang fuzzing mode", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "iphlpapi")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

   if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 23, "package(usrsctp): need ndk api level > 23")
        end)
    end

    on_install("windows", "linux", "macosx", "iphoneos", "android", "cross", "bsd", "mingw", function (package)
        local configs ={"-Dsctp_build_programs=0"}
        if package:is_debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
            table.insert(configs, "-Dsctp_debug=1")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
            table.insert(configs, "-Dsctp_debug=0")
        end

        table.insert(configs, "-Dsctp_build_shared_lib=" .. (package:config("shared") and "1" or "0"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-Dsctp_" .. name .. "=" .. (enabled and "1" or "0"))
            end
        end
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=1")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("usrsctp_init", {includes = "usrsctp.h"}))
    end)
