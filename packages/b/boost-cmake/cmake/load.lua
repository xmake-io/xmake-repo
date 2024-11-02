import("core.base.graph")

function _mangle_link_format_string(package)
    local link = "boost_%s"
    if package:is_plat("windows") and not package:config("shared") then
        link = "lib" .. link
    end
    return link
end

function _add_defines(package)
    if package:is_plat("windows") then
        package:add("defines", "BOOST_ALL_NO_LIB")
    end
    if package:config("shared") then
        package:add("defines", "BOOST_ALL_DYN_LINK")
    end
end

function _add_links(package)
    local dag = graph.new(true)

    libs.for_each(function (libname, deps)
        if package:config(libname) then
            for _, dep_libname in ipairs(deps) do
                dag:add_edge(libname, dep_libname)
            end
        end
    end)

    local links = dag:topological_sort()
    local format_str = _mangle_link_format_string(package)
    for _, libname in ipairs(links) do
        package:add("links", format(format_str, libname))
    end
end

function _recursion_enabled_dep_configs(package, libname, deps, visited_table)
    if package:config(libname) and not visited_table[libname] then
        visited_table[libname] = true
        for _, dep_libname in ipairs(deps) do
            package:config_set(dep_libname, true)
            _recursion_enabled_dep_configs(package, dep_libname, libs.get_libs()[dep_libname], visited_table)
        end
    end
end

function _auto_enabled_dep_configs(package)
    local visited_table = {}

    libs.for_each(function (libname, deps)
        _recursion_enabled_dep_configs(package, libname, deps, visited_table)
    end)
end

function _add_deps(package)
    if package:config("iostreams") then
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
            package:add("patches", "1.86.0", "patches/1.86.0/find-zstd.patch", "7a90f2cbf01fc26bc8a98d58468c20627974f30e45bdd4a00c52644b60af1ef6")
        end
    end
end

function main(package)
    import("libs", {rootdir = package:scriptdir()})

    _auto_enabled_dep_configs(package)

    _add_defines(package)

    _add_links(package)

    _add_deps(package)
end
