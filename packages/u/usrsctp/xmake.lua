package("usrsctp")
    set_homepage("https://github.com/sctplab/usrsctp")
    set_description("A portable SCTP userland stack")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/sctplab/usrsctp/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%+", ".")
    end})
    add_urls("https://github.com/sctplab/usrsctp.git")

    add_versions("0.9.5+0", "260107caf318650a57a8caa593550e39bca6943e93f970c80d6c17e59d62cd92")

    if not is_plat("bsd") then
        add_patches("0.9.5+0", "https://github.com/sctplab/usrsctp/commit/e984d7f3c1b13d0b0582497b385c93f0e8d89fb3.diff", "59c5e71379ca7e9d9849d6347cd0537ec626e6f4cbcdaa53be8f8ec828bbc419")
    end
    add_patches("0.9.5+0", "https://github.com/sctplab/usrsctp/commit/b56b4300b9ad1c0eb447b7b76a0a3f40b30716be.diff", "8d6d81d449d571284a45e9ba2beb5a206453c012f182366d89f5e5faea572d13")
    
    add_configs("invariants", {description = "Add runtime checks", default = false, type = "boolean"})
    add_configs("inet", {description = "Support IPv4", default = true, type = "boolean"})
    add_configs("inet6", {description = "Support IPv6", default = true, type = "boolean"})
    add_configs("sanitizer_memory", {description = "Compile with memory sanitizer", default = false, type = "boolean"})

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

    on_install("!wasm", function (package)
        local configs = {"-Dsctp_werror=0", "-Dsctp_build_programs=0"}
        if package:is_debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
            table.insert(configs, "-Dsctp_debug=1")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
            table.insert(configs, "-Dsctp_debug=0")
        end

        table.insert(configs, "-Dsctp_build_shared_lib=" .. (package:config("shared") and "1" or "0"))
        table.insert(configs, "-Dsctp_sanitizer_address=" .. (package:config("asan") and "1" or "0"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-Dsctp_" .. name .. "=" .. (enabled and "1" or "0"))
            end
        end
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=1")
        end
        if package:is_plat("bsd") then
            io.replace("usrsctplib/netinet/sctp_os_userspace.h", "ip6protosw.h", "ip6_var.h", {plain = true})
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("usrsctp_init", {includes = "usrsctp.h"}))
    end)
