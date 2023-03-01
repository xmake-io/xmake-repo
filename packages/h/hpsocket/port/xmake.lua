local dep_packages = {}
local options = {{name = "udp",    package = "kcp"},
                 {name = "http",   package = "http_parser"},
                 {name = "zlib",   package = is_plat("android", "windows") and "" or "zlib"},
                 {name = "brotli", package = "brotli"},
                 {name = "ssl",    package = ""},
                 {name = "iconv",  package = ""}}
local winCommonSrcPath = (get_config("hpversion") == "v5.7.3") and "Windows/Common/Src/" or "Windows/Src/Common/"
local winBuiltinDependentLibPath = (get_config("hpversion") == "v5.7.3") and "Windows/Common/Lib/" or "Windows/Dependent/"

for _, opt in ipairs(options) do
    local opt_name = "no_" .. opt.name
    option(opt_name)
        set_default(false)
        set_showmenu(true)
        set_category("option")
        set_description("Build hpsocket without " .. opt.name)
        add_defines("_" .. string.upper(opt.name) .. "_DISABLED")
    option_end()

    if not has_config(opt_name) and opt.package ~= "" then
        add_requires(opt.package, is_plat("windows") and {} or {configs = {cxflags = "-fpic"}})
        table.insert(dep_packages, opt.package)
    end
end

option("no_4c")
    set_default(false)
    set_showmenu(true)
    set_category("option")
    set_description("Build hpsocket without C interface")
option_end()

option("unicode")
    set_default(false)
    set_showmenu(true)
    set_category("option")
    set_description("Build hpsocket with unicode character set")
option_end()

option("hpversion")
    set_default("v5.9.1")
    set_showmenu(true)
    set_category("option")
    set_description("The version of HP-Socket")
option_end()

add_rules("mode.debug", "mode.release")
target("hpsocket")
    before_build(function (target)
        if is_plat("windows") then
            io.writefile("stdafx.h", [[
                #pragma once
                #include "]] .. winCommonSrcPath .. [[GeneralHelper.h"
            ]])
            io.writefile("stdafx.cpp", [[
                #include "stdafx.h"
            ]])
        end
    end)
    set_kind("$(kind)")

    for _, opt in ipairs(options) do
        add_options("no_" .. opt.name)
    end

    for _, pkg in ipairs(dep_packages) do
        add_packages(pkg)
    end

    local exclude_file
    local install_files = {}
    local no_4c = has_config("no_4c")
    set_basename(no_4c and "hpsocket" or "hpsocket4c")
    exclude_file = no_4c and "HPSocket4C.*|HPSocket4C-SSL.*" or "HPSocket.*|HPSocket-SSL.*"

    if is_plat("windows") then
        add_syslinks("ws2_32", "user32", "kernel32")
        if not has_config("no_ssl") then
            add_syslinks("crypt32")
        end
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl", "rt")
    elseif is_plat("android") then
        add_syslinks("dl")
        if not has_config("no_zlib") then
            add_syslinks("z")
        end
    end

    if is_plat("windows") then
        if has_config("unicode") then
            add_defines("UNICODE", "_UNICODE")
        end
        
        set_pcxxheader("stdafx.h")
        add_files("stdafx.cpp")
        add_files(path.join(winCommonSrcPath, "http/*.c"))
        add_files(path.join(winCommonSrcPath, "*.cpp"))
        add_files("Windows/Src/*.cpp|" .. exclude_file)
        add_headerfiles("Windows/Include/HPSocket/*.h|" .. exclude_file)
        add_defines(is_kind("shared") and "HPSOCKET_EXPORTS" or "HPSOCKET_STATIC_LIB")

        local vs = get_config("vs")
        local vs_ver = "10.0"
        if     vs == "2015" then vs_ver = "14.0"
        elseif vs == "2017" then vs_ver = "15.0"
        elseif vs == "2019" then vs_ver = "16.0"
        elseif vs == "2022" then vs_ver = "17.0"
        end
        if get_config("hpversion") == "v5.9.1" then
            vs_ver = (vs == "2015" and "100" or "14x")
        end

        add_includedirs(".")
        add_includedirs(path.join(winBuiltinDependentLibPath, "openssl", vs_ver, "$(arch)", "include"))
        ssllinkdir = path.join(winBuiltinDependentLibPath, "openssl", vs_ver, "$(arch)", "lib")
        add_linkdirs(ssllinkdir)
        add_includedirs(path.join(winBuiltinDependentLibPath, "zlib", vs_ver, "$(arch)", "include"))
        zliblinkdir = path.join(winBuiltinDependentLibPath, "zlib", vs_ver, "$(arch)", "lib")
        add_linkdirs(zliblinkdir)

        if not has_config("no_ssl") then
            add_links("libssl", "libcrypto")
            if is_kind("static") then
                table.insert(install_files, path.join(ssllinkdir, "*.lib"))
            end
        end
        
        if not has_config("no_zlib") then
            add_links("zlib")
            if is_kind("static") then
                table.insert(install_files, path.join(zliblinkdir, "*.lib"))
            end
        end
    elseif is_plat("linux", "android") then
        add_cxflags("-fpic", {force = true})
        add_files("Linux/src/common/crypto/*.cpp")
        add_files("Linux/src/common/http/*.c")
        add_files("Linux/src/common/*.cpp")
        add_files("Linux/src/*.cpp|" .. exclude_file)
        add_headerfiles("Linux/include/hpsocket/*.h|" .. exclude_file)
        add_headerfiles("Linux/include/hpsocket/(common/*.h)")

        if is_plat("android") then
            add_includedirs("Linux/dependent/android-ndk/$(arch)/include")
            linkdir = "Linux/dependent/android-ndk/$(arch)/lib"
            add_linkdirs(linkdir)
            if not has_config("no_iconv") then
                add_links("charset", "iconv")
                if is_kind("static") then
                    table.insert(install_files, path.join(linkdir, "libcharset.a"))
                    table.insert(install_files, path.join(linkdir, "libiconv.a"))
                end
            end
        else
            local arch = is_arch("x86_64") and "x64" or "x86"
            add_includedirs(path.join("Linux/dependent", arch, "include"))
            linkdir = path.join("Linux/dependent", arch, "lib")
            add_linkdirs(linkdir)
            add_links("jemalloc_pic")
            if is_kind("static") then
                table.insert(install_files, path.join(linkdir, "libjemalloc_pic.a"))
            end
        end

        if not has_config("no_ssl") then
            add_links("ssl", "crypto")
            if is_kind("static") then
                table.insert(install_files, path.join(linkdir, "libssl.a"))
                table.insert(install_files, path.join(linkdir, "libcrypto.a"))
            end
        end
    end

    for _, file in ipairs(install_files) do
        add_installfiles(file, {prefixdir = "lib"})
    end