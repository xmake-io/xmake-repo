package("proj")
    set_homepage("https://proj.org/index.html")
    set_description("PROJ is a generic coordinate transformation software that transforms geospatial coordinates from one coordinate reference system (CRS) to another.")
    set_license("MIT")

    add_urls("https://download.osgeo.org/proj/proj-$(version).tar.gz")
    add_versions("9.4.0", "3643b19b1622fe6b2e3113bdb623969f5117984b39f173b4e3fb19a8833bd216")
    add_versions("9.0.1", "737eaacbe7906d0d6ff43f0d9ebedc5c734cccc9e6b8d7beefdec3ab22d9a6a3")
    add_versions("8.2.1", "76ed3d0c3a348a6693dfae535e5658bbfd47f71cb7ff7eb96d9f12f7e068b1cf")

    add_configs("apps", {description = "Build PROJ applications.", default = false, type = "boolean"})
    add_configs("tiff", {description = "Enable TIFF support.", default = false, type = "boolean"})
    add_configs("curl", {description = "Enable Curl support.", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("shell32", "ole32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("dl", "pthread")
    end

    add_deps("cmake", "sqlite3")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_load(function (package)
        if package:config("tiff") then
            package:add("deps", "libtiff")
        end
        if package:config("curl") then
            package:add("deps", "libcurl")
        end
        if package:config("apps") then
            package:addenv("PATH", "bin")
        end

        if not package:config("shared") then
            package:add("defines", "PROJ_DLL=")
        end
    end)

    on_install("!wasm and (!android or android@!windows)", function (package)
        -- windows@arm64 cann't generate proj.db
        if package:is_plat("windows") and package:is_arch("arm64") then
            io.replace("CMakeLists.txt", "add_subdirectory(data)", "", {plain = true})
        end
        if package:config("curl") and (package:version():le(9.4)) then
            io.replace("src/lib_proj.cmake", "${CURL_LIBRARIES}", "CURL::libcurl", {plain = true})
        end
        local configs = {"-DNLOHMANN_JSON_ORIGIN=external", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_APPS=" .. (package:config("apps") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_TIFF=" .. (package:config("tiff") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_CURL=" .. (package:config("curl") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_PROJSYNC=" .. (package:config("curl") and "ON" or "OFF"))

        if package:config("curl") and package:is_plat("macosx") then
            local exflags = {"-framework", "CoreFoundation", "-framework", "Security", "-framework", "SystemConfiguration"}
            import("package.tools.cmake").install(package, configs, {shflags = exflags, ldflags = exflags})
        else
            import("package.tools.cmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("proj_context_create", {includes = "proj.h"}))
    end)
