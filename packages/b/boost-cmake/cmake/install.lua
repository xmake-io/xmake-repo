function _add_libs(package, configs)
    local include_libs = {}
    local exclude_libs = {}

    libs.for_each(function (libname)
        if package:config(libname) then
            table.insert(include_libs, libname)
        else
            table.insert(exclude_libs, libname)
        end
    end)
    table.insert(configs, "-DBOOST_INCLUDE_LIBRARIES=" .. table.concat(include_libs, ";"))
    table.insert(configs, "-DBOOST_EXCLUDE_LIBRARIES=" .. table.concat(exclude_libs, ";"))
end

function _add_iostreams_configs(package, configs)
    local iostreams_deps = {"zlib", "bzip2", "lzma", "zstd"}
    for _, dep in ipairs(iostreams_deps) do
        local config = format("-DBOOST_IOSTREAMS_ENABLE_%s=%s", dep:upper(), (package:config(dep) and "ON" or "OFF"))
        table.insert(configs, config)
    end
end

function main(package)
    import("libs", {rootdir = package:scriptdir()})

    local configs = {"-DBOOST_INSTALL_LAYOUT=system"}
    table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
    table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
    if package:is_plat("windows") then
        table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
    end

    _add_libs(package, configs)

    _add_iostreams_configs(package, configs)

    local opt = {}
    opt.cxflags = {}
    local lzma = package:dep("xz")
    if lzma and not lzma:config("shared") then
        table.insert(opt.cxflags, "-DLZMA_API_STATIC")
    end
    
    if package:is_plat("windows") then
        table.insert(opt.cxflags, "/EHsc")
    end
    import("package.tools.cmake").install(package, configs, opt)
end
