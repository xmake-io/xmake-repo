import("lib.detect.find_path")
import("lib.detect.find_file")
import("lib.detect.find_library")
import("core.base.semver")

-- http://www.slproweb.com/products/Win32OpenSSL.html
function _find_package_on_windows(package, opt)
    local bits = package:is_plat("x86") and "32" or "64"
    local paths = {"$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL %(" .. bits .. "-bit%)_is1;Inno Setup: App Path)",
                    "$(env PROGRAMFILES)/OpenSSL",
                    "$(env PROGRAMFILES)/OpenSSL-Win" .. bits,
                    "C:/OpenSSL",
                    "C:/OpenSSL-Win" .. bits}

    local result = {links = {}, linkdirs = {}}
    local suffix = package:config("shared") and "" or "_static"
    for _, name in ipairs({"libssl" .. suffix, "libcrypto" .. suffix}) do
        local linkinfo = find_library(name, paths, {suffixes = "lib"})
        if linkinfo then
            table.insert(result.links, linkinfo.link)
            table.insert(result.linkdirs, linkinfo.linkdir)
        end
    end
    if #result.links == 0 then
        -- find light package
        local arch = package:arch()
        for _, name in ipairs({"libssl-3-" .. arch, "libcrypto-3-" .. arch}) do
            local linkinfo = find_library(name, paths)
            if linkinfo then
                table.insert(result.links, linkinfo.link)
                table.insert(result.linkdirs, linkinfo.linkdir)
            end
        end
    end
    if #result.links ~= 2 then
        return
    end
    if result.linkdirs then
        result.linkdirs = table.unique(result.linkdirs)
    end
    local includedir = find_path(path.translate("openssl/ssl.h"), paths, {suffixes = "include"})
    if includedir then
        result.includedirs = result.includedirs or {}
        table.insert(result.includedirs, includedir)
    end
    local openssl = find_file("openssl.exe", paths, {suffixes = "bin"})
    if openssl then
        local version = try {function () return os.iorunv(openssl, {"version"}) end}
        if version then
            result.version = semver.match(version)
        end
    end
    return result
end

function main(package, opt)
    if opt.system and package.find_package then
        local result
        if package:is_plat("windows", "mingw", "msys") and is_host("windows") then
            result = _find_package_on_windows(package, opt)
        else
            result = package:find_package("openssl", opt)
        end
        return result or false
    end
end

