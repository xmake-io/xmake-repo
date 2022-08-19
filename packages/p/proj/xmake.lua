package("proj")

    set_homepage("https://proj.org/index.html")
    set_description("PROJ is a generic coordinate transformation software that transforms geospatial coordinates from one coordinate reference system (CRS) to another.")
    set_license("MIT")

    add_urls("https://download.osgeo.org/proj/proj-$(version).tar.gz")
    add_versions("9.0.1", "737eaacbe7906d0d6ff43f0d9ebedc5c734cccc9e6b8d7beefdec3ab22d9a6a3")

    add_configs("apps", {description = "Build PROJ applications.", default = true, type = "boolean"})
    add_configs("tiff", {description = "Enable TIFF support.", default = false, type = "boolean"})
    add_configs("curl", {description = "Enable Curl support.", default = false, type = "boolean"})

    add_deps("cmake", "sqlite3")
    add_deps("nlohmann_json", {configs = {cmake = true}})
    if is_plat("windows") then
        add_syslinks("shell32", "ole32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
    on_load("windows", "macosx", "linux", function (package)
        if package:config("tiff") then
            package:add("deps", "libtiff")
        end
        if package:config("curl") then
            package:add("deps", "libcurl")
            if package:is_plat("linux") then
                package:add("deps", "openssl")
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        if package:config("curl") and package:is_plat("linux") then
            io.replace("src/lib_proj.cmake", "${CURL_LIBRARIES}", "CURL::libcurl ssl crypto", {plain = true})
        else
            io.replace("src/lib_proj.cmake", "${CURL_LIBRARIES}", "CURL::libcurl", {plain = true})
        end
        if package:is_plat("windows") and not package:config("shared") then
            io.replace("src/proj.h", "#ifndef PROJ_DLL", "#define PROJ_DLL\n#ifndef PROJ_DLL", {plain = true})
        end
        local configs = {"-DNLOHMANN_JSON_ORIGIN=external", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_APPS=" .. (package:config("apps") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_TIFF=" .. (package:config("tiff") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_CURL=" .. (package:config("curl") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_PROJSYNC=" .. (package:config("curl") and "ON" or "OFF"))
        if package:config("curl") and package:is_plat("linux") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"openssl"}})
        elseif package:config("curl") and package:is_plat("macosx") then
            local exflags = {"-framework", "CoreFoundation", "-framework", "Security", "-framework", "SystemConfiguration"}
            import("package.tools.cmake").install(package, configs, {shflags = exflags, ldflags = exflags})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("proj_context_create", {includes = "proj.h"}))
    end)
