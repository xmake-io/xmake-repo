import("lib.detect.find_library")
import("lib.detect.find_tool")
import("core.base.semver")

function _get_python_libs()
    local opt = {version = true}
    local result = find_tool("python3", opt)
    if not result then
        result = find_tool("python", opt)
    end

    local libs = {}
    local version = result and result.version
    if version then
        local py_ver = semver.new(version)
        py_ver = py_ver:major() .. py_ver:minor()
        table.insert(libs, "python" .. py_ver)
        table.insert(libs, "numpy" .. py_ver)
    end
    return libs
end

function _add_info(linkinfo, result)
    table.insert(result.linkdirs, linkinfo.linkdir)
    if linkinfo.filename then
        local filepath = path.join(linkinfo.linkdir, linkinfo.filename)
        if os.isfile(filepath) then
            table.insert(result.libfiles, filepath)
        end
    end
    table.insert(result.links, linkinfo.link)
end

function main(package, opt)
    if opt.system then
        import("libs", {rootdir = package:scriptdir()})

        local paths = {
            "/usr/lib",
            "/usr/lib64",
            "/usr/local/lib",
            "/usr/lib/x86_64-linux-gnu",
        }

        local result = {
            libfiles = {},
            linkdirs = {},
            links = {},
        }

        local opt = {
            plat = package:plat(),
            kind = package:config("shared") and "shared" or "static",
        }

        local sub_libs_map = libs.get_sub_libs(package)
        sub_libs_map.python = _get_python_libs()
        table.insert(sub_libs_map.test, "test_exec_monitor")

        local found
        libs.for_each(function (libname)
            local sub_libs = sub_libs_map[libname]
            for _, sub_libname in ipairs(sub_libs or {libname}) do
                local linkinfo = find_library("boost_" .. sub_libname, paths, opt)
                if linkinfo then
                    _add_info(linkinfo, result)
                    found = true
                end
            end
        end)

        -- Link python if boost_python is found
        for _, libname in ipairs(sub_libs_map.python or {}) do
            if libname:startswith("python") and table.contains(result.links, "boost_" .. libname) then
                local py_linkinfo = find_library("python3", paths) or find_library("python", paths)
                if py_linkinfo then
                    _add_info(py_linkinfo, result)
                end
            end
        end

        if found then
            result.linkdirs = table.unique(result.linkdirs)
            return result
        end
    end
end
