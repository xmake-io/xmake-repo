import("core.base.graph")

function _mangle_link(libname)
    return "boost_" .. libname
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
        package:add("links", _mangle_link(libname))
    end
end
