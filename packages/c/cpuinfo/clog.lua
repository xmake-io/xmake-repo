function main(package)
    os.cd("deps/clog")
    local configs = {"-DCLOG_BUILD_TESTS=OFF"}
    table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
    table.insert(configs, "-DCLOG_RUNTIME_TYPE=" .. (package:config("shared") and "shared" or "static"))
    if package:config("shared") and package:is_plat("windows") then
        table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
    end
    import("package.tools.cmake").install(package, configs)
end
