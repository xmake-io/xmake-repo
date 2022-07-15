import("lib.detect.find_path")
import("lib.detect.find_library")

-- http://www.slproweb.com/products/Win32OpenSSL.html
function _find_package_on_windows(package, opt)
    local bits = package:is_plat("x86") and "32" or "64"
    local paths = {"$(reg HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL %(" .. bits .. "-bit%)_is1;Inno Setup: App Path)",
                    "$(env PROGRAMFILES)/OpenSSL",
                    "$(env PROGRAMFILES)/OpenSSL-Win" .. bits,
                    "C:/OpenSSL",
                    "C:/OpenSSL-Win" .. bits}

    local result = {links = {}, linkdirs = {}, includedirs = {}}
    for _, name in ipairs({"libssl", "libcrypto"}) do
        local linkinfo = find_library(name, paths, {suffixes = "lib"})
        if linkinfo then
            table.insert(result.links, linkinfo.link)
            table.insert(result.linkdirs, linkinfo.linkdir)
        end
    end
    if #result.links ~= 2 then
        return
    end
    table.insert(result.includedirs, find_path(path.translate("openssl/ssl.h"), paths, {suffixes = "include"}))
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
