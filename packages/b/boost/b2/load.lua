function _get_linkname(package, libname)
    local linkname
    if package:is_plat("windows") then
        linkname = (package:config("shared") and "boost_" or "libboost_") .. libname
    else
        linkname = "boost_" .. libname
    end
    if libname == "python" or libname == "numpy" then
        linkname = linkname .. package:config("pyver"):gsub("%p+", "")
    end
    if package:config("multi") then
        linkname = linkname .. "-mt"
    end
    if package:is_plat("windows") then
        if package:config("shared") then
            if package:debug() then
                linkname = linkname .. "-gd"
            end
        elseif package:config("asan") or package:has_runtime("MTd") then
            linkname = linkname .. "-sgd"
        elseif package:has_runtime("MT") then
            linkname = linkname .. "-s"
        elseif package:config("asan") or package:has_runtime("MDd") then
            linkname = linkname .. "-gd"
        end
    else
        if package:debug() then
            linkname = linkname .. "-d"
        end
    end
    return linkname
end

function main(package)
    import("libs", {rootdir = package:scriptdir()})

    -- we need the fixed link order
    local headeronly = not package:config("all")
    local sublibs = {log = {"log_setup", "log"},
                    python = {"python", "numpy"},
                    stacktrace = {"stacktrace_backtrace", "stacktrace_basic"}}

    libs.for_each(function (libname)
        if package:config(libname) then
            headeronly = false
        end
        local libs = sublibs[libname]
        if libs then
            for _, lib in ipairs(libs) do
                package:add("links", _get_linkname(package, lib))
            end
        else
            package:add("links", _get_linkname(package, libname))
        end
    end)

    if headeronly then
        package:set("kind", "library", {headeronly = true})
    end
    -- disable auto-link all libs
    if package:is_plat("windows") then
        package:add("defines", "BOOST_ALL_NO_LIB")
        if package:config("shared") then
            package:add("defines", "BOOST_ALL_DYN_LINK")
        end
    end

    if package:config("python") then
        if not package:config("shared") then
            package:add("defines", "BOOST_PYTHON_STATIC_LIB")
        end
        package:add("deps", "python " .. package:config("pyver") .. ".x", {configs = {headeronly = true}})
    end
    if package:config("zstd") then
        package:add("deps", "zstd")
    end
    if package:config("lzma") then
        package:add("deps", "xz")
    end
    if package:config("zlib") then
        package:add("deps", "zlib")
    end
    if package:config("bzip2") then
        package:add("deps", "bzip2")
    end

    if package:is_plat("windows") and package:version():le("1.85.0") then
        local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
        if vs_toolset then
            local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
            local minor = vs_toolset_ver:minor()
            if minor and minor >= 44 then
                package:add("patches", "<=1.85.0", "patches/1.85.0/fix-msvc.patch", "e3c9fcfa424581c385e0346bd747f38d83fe8dcda9a5a9b87fb11796209c52ca")
            end
        end
    end
end
