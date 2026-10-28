function add_urls(package, scheme_name)
    local scheme = package:scheme(scheme_name)
    local plat = package:is_toolchain() and os.host() or package:plat()
    local arch = package:is_toolchain() and os.arch() or package:arch()
    if plat == "windows" or (package:is_toolchain() and (plat == "linux" or plat == "macosx")) then
        import("schemes.binary." .. plat, {rootdir = package:scriptdir()}).add_urls(scheme, arch)
    end
end

function install(package)
    os.cp("*", package:installdir(), {symlink = true})
end
