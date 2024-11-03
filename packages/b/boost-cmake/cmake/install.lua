import("core.base.hashset")
import("core.base.option")

function _mangle_link_format_string(package)
    local link = "boost_%s"
    if package:is_plat("windows") and not package:config("shared") then
        link = "lib" .. link
    end
    return link
end
-- Only get package dep version in on_install
function _add_links(package)
    local format_str = _mangle_link_format_string(package)
    libs.for_each(function (libname)
        if not package:config(libname) then
            return
        end

        if libname == "test" then
            package:add("links", format(format_str, "prg_exec_monitor"))
            package:add("links", "libboost_test_exec_monitor") -- always static
            package:add("links", format(format_str, "unit_test_framework"))
            return
        elseif libname == "stacktrace" then
            package:add("links", format(format_str, "stacktrace_noop"))
            package:add("links", format(format_str, "stacktrace_backtrace"))
            package:add("links", format(format_str, "stacktrace_addr2line"))
            package:add("links", format(format_str, "stacktrace_basic"))
            package:add("links", format(format_str, "stacktrace_windbg"))
            package:add("links", format(format_str, "stacktrace_windbg_cached"))
            return
        end

        if libname == "python" then
            local py_ver = assert(package:dep("python"):version(), "Can't get python version")
            libname = libname .. py_ver:major() .. py_ver:minor()
        end
        package:add("links", format(format_str, libname))

        -- TODO: Add to libs.lua?
        if libname == "serialization" then
            package:add("links", format(format_str, "wserialization"))
        elseif libname == "fiber" then
            package:add("links", format(format_str, "fiber_numa"))
        elseif libname == "log" then
            package:add("links", format(format_str, "log_setup"))
        end
    end)
end

function _check_links(package)
    local lib_files = {}
    local links = hashset.from(table.wrap(package:get("links")))

    for _, libfile in ipairs(os.files(package:installdir("lib/*"))) do
        local link = path.basename(libfile)
        if not links:remove(link) then
            table.insert(lib_files, path.filename(libfile))
        end
    end

    links = links:to_array()
    if #links ~= 0 then
        -- TODO: Remove header only "link"
        wprint("Missing library files\n" .. table.concat(links, "\n"))
    end
    if #lib_files ~= 0 then
        wprint("Missing links\n" .. table.concat(lib_files, "\n"))
    end
end

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

    table.insert(configs, "-DBOOST_ENABLE_PYTHON=" .. (package:config("python") and "ON" or "OFF"))
    if package:config("locale") then
        table.insert(configs, "-DCMAKE_CXX_STANDARD=17")
    end

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

    _add_links(package)

    if option.get("verbose") then
        _check_links(package)
    end
end
