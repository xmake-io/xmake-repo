import("core.base.graph")

function _mangle_link(package, libname)
    local link = "boost_" .. libname
    if package:is_plat("windows") and not package:config("shared") then
        link = "lib" .. link
    end
    return link
end

function _add_defines(package)
    if package:is_plat("windows") then
        package:add("defines", "BOOST_ALL_NO_LIB")
    end
end

function _add_links(package)
    local dag = graph.new(true)

    libs.for_each(function (libname, deps)
        if package:config(libname) then
            for _, dep_lib in ipairs(deps) do
                dag:add_edge(libname, dep_lib)
            end
        end
    end)

    local links = dag:topological_sort()
    for _, libname in ipairs(links) do
        package:add("links", _mangle_link(package, libname))
    end
end

function main(package)
    import("libs", {rootdir = package:scriptdir()})

    libs.for_each(function (libname, deps)
        if package:config(libname) then
            for _, dep_lib in ipairs(deps) do
                package:config_set(dep_lib, true)
            end
        end
    end)

    _add_defines(package)
    _add_links(package)
end
