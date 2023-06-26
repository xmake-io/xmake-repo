package("drogon")

    set_homepage("https://github.com/an-tao/drogon/")
    set_description("Drogon: A C++14/17/20 based HTTP web application framework running on Linux/macOS/Unix/Windows")
    set_license("MIT")

    add_urls("https://github.com/an-tao/drogon/archive/refs/tags/$(version).tar.gz",
             "https://github.com/an-tao/drogon.git")
    add_versions("v1.4.1", "ad794d7744b600240178348c15e216c919fe7a2bc196cf1239f129aee2af19c7")
    add_versions("v1.6.0", "9f8802b579aac29e9eddfb156e432276727a3d3c49fffdf453a2ddcd1cb69093")
    add_versions("v1.7.1", "a0bce1f32b6e1321486bb25c55ca7bd7a577cbd53f1e7be47367d0f9733730f1")
    add_versions("v1.7.3", "36dc5a3acad3b8a32bb1364764b26cf01c687a4f62358de9632e055b156313a6")
    add_versions("v1.7.5", "e2af7c55dcabafef16f26f5b3242692f5a2b54c19b7b626840bf9132d24766f6")
    add_versions("v1.8.0", "bc6503cf213ed961d4a5e9fd7cb8e75b6b11045a67840ea2241e57321dd8711b")
    add_versions("v1.8.1", "9665f001355cc72a5a9db941ae349cec50959d18bf44eb6c09311bf9c78336a4")
    add_versions("v1.8.2", "1182cab00c33e400eac617c6dbf44fa2f358e1844990b6b8c5c87783024f9971")

    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "trantor.patch"), "7f9034a27bb63de8dedb80dd9f246ea7aa7724c87f2c0d0054f4b6097ea2a862")
    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "resolv.patch" ), "a1054822bf91f5f06de8bca9b1bd8859233228159a8ff8014ce6329d6c000f26")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "trantor.patch"), "87e317bf5e45b3f3dfe781db8a0af9603ebdab057a6aedbc36d8aec9e0da58a7")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "resolv.patch" ), "dc144ff1cdcfee413efbcdc568fed587318289e8fa1bb0da9d2ea94a15588b25")
    add_patches("1.7.1", path.join(os.scriptdir(), "patches", "1.7.1", "trantor.patch"), "3f93a1e78ba45c8f1e85c28d4fdbbd3e7961078da8cf417a97d8797a91fa2167")
    add_patches("1.7.1", path.join(os.scriptdir(), "patches", "1.7.1", "resolv.patch" ), "75d3618374d15a5ec12681c8659e183f3e620acc43c77ae66e7bea21a25ca546")
    add_patches(">=1.7.3 <1.8.0", path.join(os.scriptdir(), "patches", "1.7.3", "trantor.patch"), "27e479dd0e3f8adc75c9c21fe895937f727c3102e5bfb21ac3289d6ad2795b7a")
    add_patches(">=1.7.3 <1.8.0", path.join(os.scriptdir(), "patches", "1.7.3", "resolv.patch" ), "49694f090e169a5c0e524726e8b85ad0bac76c05ed633c60e986849c2e5adb85")
    add_patches("1.8.0",   path.join(os.scriptdir(), "patches", "1.8.0", "redis.patch" ), "cf09beb4f07fd970ef4ad8911eec71ce7c94609ad9fbf1626b5ca8fcd070e09e")
    add_patches(">=1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "resolv.patch"), "e9b6b320c70d17024931be8481f7b6413681216113466b5d6699431bb98d50e2")
    add_patches(">=1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "config.patch"), "67a921899a24c1646be6097943cc2ed8228c40f177493451f011539c6df0ed76")

    add_configs("c_ares", {description = "Enable async DNS query support.", default = false, type = "boolean"})
    add_configs("mysql", {description = "Enable mysql support.", default = false, type = "boolean"})
    add_configs("openssl", {description = "Enable openssl support.", default = true, type = "boolean"})
    add_configs("postgresql", {description = "Enable postgresql support.", default = false, type = "boolean"})
    add_configs("sqlite3", {description = "Enable sqlite3 support.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("trantor", "jsoncpp", "brotli", "zlib")

    if is_plat("windows") then
        add_syslinks("ws2_32", "rpcrt4", "crypt32", "advapi32", "iphlpapi")
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
                    else
                        table.insert(configs, "-DBUILD_" .. name:upper() .. "=ON")
                    end
                else
                    if name == "sqlite3" then
                        table.insert(configs, "-DBUILD_SQLITE=OFF")
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
