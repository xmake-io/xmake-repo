package("civetweb")

    set_homepage("https://github.com/civetweb/civetweb")
    set_description("Embedded C/C++ web server")
    set_license("MIT")

    add_urls("https://github.com/civetweb/civetweb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/civetweb/civetweb.git")
    add_versions('v1.15', '90a533422944ab327a4fbb9969f0845d0dba05354f9cacce3a5005fa59f593b9')
    add_patches("v1.15", path.join(os.scriptdir(), "patches", "v1.15", "find-winsock.patch"), "19f0008f13d7a7eceb026c51452c8cac2b3f1841f7ac7c558552e0522cdb1edc")

    add_configs("openssl", {description = "with openssl library", default = false, type = "boolean"})
    add_configs("zlib",    {description = "Enable zlib support.", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("linux") or is_plat("bsd") then
        add_syslinks("pthread")
    elseif is_plat("mingw", "windows") then
        add_syslinks("ws2_32")
    end

    on_load(function (package)
        local configdeps = {
            openssl = "openssl",
            zlib    = "zlib",
        }
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
    end)

    on_install(function (package)
        local configs = {
            "-DCIVETWEB_BUILD_TESTING=OFF",
            "-DCIVETWEB_ENABLE_DEBUG_TOOLS=OFF",
            "-DCIVETWEB_ENABLE_CXX=ON",
            "-DCIVETWEB_ENABLE_SERVER_EXECUTABLE=OFF",
            "-DCIVETWEB_ENABLE_WEBSOCKETS=ON",
            "-DCIVETWEB_ENABLE_SSL_DYNAMIC_LOADING=OFF",
            "-DCIVETWEB_ENABLE_IPV6=ON",
        }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCIVETWEB_ENABLE_SSL=" .. (package:config("openssl") and "ON" or "OFF"))
        table.insert(configs, "-DCIVETWEB_ENABLE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs, {shflags = shflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mg_start", {includes = "civetweb.h"}))
    end)
