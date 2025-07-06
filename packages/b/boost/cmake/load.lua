function _add_defines(package)
    if package:is_plat("windows") then
        package:add("defines", "BOOST_ALL_NO_LIB")
    end
    if package:config("shared") then
        package:add("defines", "BOOST_ALL_DYN_LINK")
    end
end

function _recursion_enabled_dep_configs(package, libname, deps, visited_table)
    if package:config(libname) and not visited_table[libname] then
        visited_table[libname] = true
        for _, dep_libname in ipairs(deps) do
            package:config_set(dep_libname, true)
            _recursion_enabled_dep_configs(package, dep_libname, libs.get_lib_deps()[dep_libname], visited_table)
        end
    end
end

function _auto_enabled_dep_configs(package)
    -- workaround
    if package:config("locale") then
        package:config_set("regex", true)
    end
    if package:config("python") then
        package:config_set("thread", true)
    end

    local visited_table = {}

    libs.for_each_lib_deps(function (libname, deps)
        _recursion_enabled_dep_configs(package, libname, deps, visited_table)
    end)
end

function _add_iostreams_deps(package)
    if package:config("zlib") then
        package:add("deps", "zlib")
    end
    if package:config("bzip2") then
        package:add("deps", "bzip2")
    end
    if package:config("lzma") then
        package:add("deps", "xz")
    end

    if package:config("zstd") then
        package:add("deps", "zstd")

        package:add("deps", (is_subhost("windows") and "pkgconf") or "pkg-config")
        package:add("patches", ">=1.86.0", "patches/1.86.0/find-zstd.patch", "7a90f2cbf01fc26bc8a98d58468c20627974f30e45bdd4a00c52644b60af1ef6")
    end
end

function _add_deps(package)
    if package:config("regex") and package:config("icu") then
        package:add("deps", "icu4c")
    end
    if package:config("locale") then
        package:add("deps", "libiconv")
        if package:config("icu") then
            package:add("deps", "icu4c")
        end
    end
    if package:config("python") then
        package:add("deps", "python", {configs = {headeronly = true}})
    end
    if package:config("openssl") then
        package:add("deps", "openssl >=1.1.1-a") -- same as python on_load
    end
    if package:config("iostreams") then
        _add_iostreams_deps(package)
    end
end

function _add_header_only_configs(package)
    libs.for_each(function (libname)
        package:config_set(libname, false)
    end)
    -- TODO: find cmake option to install header only library
    -- libs.for_each_header_only_buildable_lib(function (libname)
    --     package:config_set(libname, true)
    -- end)
end

function main(package)
    import("libs", {rootdir = package:scriptdir()})

    if package:config("header_only") then
        package:set("kind", "library", {headeronly = true})
        _add_header_only_configs(package)
    else
        if package:config("all") then
            package:config_set("openssl", true) -- mysql/redis require
            libs.for_each(function (libname)
                package:config_set(libname, true)
            end)
        else
            _auto_enabled_dep_configs(package)
        end
    end

    if package:config("mpi") then
        -- TODO: add mpi to xrepo
        package:config_set("mpi", false)
        wprint("package(boost) Unsupported mpi config")
    end

    _add_deps(package)

    _add_defines(package)
end
