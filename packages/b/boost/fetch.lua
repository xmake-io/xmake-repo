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
            if sub_libs then
                for _, sub_libname in ipairs(sub_libs) do
                    local linkinfo = find_library("boost_" .. sub_libname, paths, opt)
                    if linkinfo then
                        _add_info(linkinfo, result)
                        found = true
                    end
                end
            else
                local linkinfo = find_library("boost_" .. libname, paths, opt)
                if linkinfo then
                    _add_info(linkinfo, result)
                    found = true
                end
            end
        end)

        if found then
            result.linkdirs = table.unique(result.linkdirs)
            return result
        end
    end
end
