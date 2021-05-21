package("drogon")

    set_homepage("https://github.com/an-tao/drogon/")
    set_description("Drogon: A C++14/17 based HTTP web application framework running on Linux/macOS/Unix/Windows")
    set_license("MIT")

    add_urls("https://github.com/an-tao/drogon/archive/refs/tags/$(version).tar.gz",
             "https://github.com/an-tao/drogon.git")
    add_versions("v1.4.1", "ad794d7744b600240178348c15e216c919fe7a2bc196cf1239f129aee2af19c7")
    add_versions("v1.6.0", "9f8802b579aac29e9eddfb156e432276727a3d3c49fffdf453a2ddcd1cb69093")

    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "trantor.patch"), "7f9034a27bb63de8dedb80dd9f246ea7aa7724c87f2c0d0054f4b6097ea2a862")
    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "resolv.patch"), "a1054822bf91f5f06de8bca9b1bd8859233228159a8ff8014ce6329d6c000f26")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "trantor.patch"), "87e317bf5e45b3f3dfe781db8a0af9603ebdab057a6aedbc36d8aec9e0da58a7")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "resolv.patch"), "dc144ff1cdcfee413efbcdc568fed587318289e8fa1bb0da9d2ea94a15588b25")

    add_configs("c_ares", {description = "Enable async DNS query support.", default = false, type = "boolean"})
    add_configs("mysql", {description = "Enable mysql support.", default = false, type = "boolean"})
    add_configs("openssl", {description = "Enable openssl support.", default = true, type = "boolean"})
    add_configs("postgresql", {description = "Enable postgresql support.", default = false, type = "boolean"})
    add_configs("sqlite3", {description = "Enable sqlite3 support.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("trantor", "jsoncpp", "brotli", "zlib")

    if is_plat("windows") then
        add_syslinks("ws2_32", "rpcrt4", "crypt32", "advapi32")
    else
        add_deps("libuuid")
        if is_plat("linux") then
            add_syslinks("pthread", "dl")
        end
    end

    on_load(function(package)
        local configdeps = {c_ares     = "c-ares",
                            mysql      = "mysql",
                            openssl    = "openssl",
                            postgresql = "postgresql",
                            sqlite3    = "sqlite3"}

        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows|x64", "macosx", "linux", function (package)
        io.replace("cmake/templates/config.h.in", "\"@COMPILATION_FLAGS@@DROGON_CXX_STANDARD@\"", "R\"(@COMPILATION_FLAGS@@DROGON_CXX_STANDARD@)\"", {plain = true})

        local configs = {"-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))

        -- no support for windows shared library
        if not package:is_plat("windows") then
            table.insert(configs, "-DBUILD_DROGON_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        end

        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    if name == "sqlite3" then
                        table.insert(configs, "-DBUILD_SQLITE=ON")
                    elseif name == "c_ares" or "openssl" then
                    else
                        table.insert(configs, "-DBUILD_" .. name:upper() .. "=ON")
                    end
                else
                    if name == "sqlite3" then
                        table.insert(configs, "-DBUILD_SQLITE=OFF")
                    elseif name == "c_ares" or "openssl" then
                    else
                        table.insert(configs, "-DBUILD_" .. name:upper() .. "=OFF")
                    end
                end
            end
        end

        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("drogon::getVersion()", {configs = {languages = "c++17"}, includes = "drogon/drogon.h"}))
    end)
