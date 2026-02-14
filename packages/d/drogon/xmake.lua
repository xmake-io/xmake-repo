package("drogon")
    set_homepage("https://github.com/an-tao/drogon/")
    set_description("Drogon: A C++14/17/20 based HTTP web application framework running on Linux/macOS/Unix/Windows")
    set_license("MIT")

    add_urls("https://github.com/an-tao/drogon/archive/refs/tags/$(version).tar.gz",
             "https://github.com/an-tao/drogon.git", {submodules = false})

    add_versions("v1.9.12", "becc3c4f3b90f069f814baef164a7e3a2b31476dc6fe249b02ff07a13d032f48")
    add_versions("v1.9.11", "f50098bb21bd0013f8da16b796313816bf79b0ecb1d74bfe33216d5400ab2002")
    add_versions("v1.9.10", "5de93fe16682388f363bb4b26ab00b0253d39108d8e7f53d5637c1b7da59a48f")
    add_versions("v1.9.9", "4155f78196902ef2f9d06b708897c9e8acaa1536cc4a8c8da9726ceb8ada2aaf")
    add_versions("v1.9.8", "62332a4882cc7db1c7cf04391b65c91ddf6fcbb49af129fc37eb0130809e0449")
    add_versions("v1.9.6", "a81d0ea0e87b0214aa56f7fa7bb851011efe606af67891a0945825104505a08a")
    add_versions("v1.9.5", "ec17882835abeb0672db29cb36ab0c5523f144d5d8ff177861b8f5865803eaae")
    add_versions("v1.9.4", "b23d9d01d36fb1221298fcdbedcf7fd3e1b8b8821bf6fb8ed073c8b0c290d11d")
    add_versions("v1.9.3", "fb4ef351b3e4c06ed850cfbbf50c571502decb1738fb7d62a9d7d70077c9fc23")
    add_versions("v1.4.1", "ad794d7744b600240178348c15e216c919fe7a2bc196cf1239f129aee2af19c7")
    add_versions("v1.6.0", "9f8802b579aac29e9eddfb156e432276727a3d3c49fffdf453a2ddcd1cb69093")
    add_versions("v1.7.1", "a0bce1f32b6e1321486bb25c55ca7bd7a577cbd53f1e7be47367d0f9733730f1")
    add_versions("v1.7.3", "36dc5a3acad3b8a32bb1364764b26cf01c687a4f62358de9632e055b156313a6")
    add_versions("v1.7.5", "e2af7c55dcabafef16f26f5b3242692f5a2b54c19b7b626840bf9132d24766f6")
    add_versions("v1.8.0", "bc6503cf213ed961d4a5e9fd7cb8e75b6b11045a67840ea2241e57321dd8711b")
    add_versions("v1.8.1", "9665f001355cc72a5a9db941ae349cec50959d18bf44eb6c09311bf9c78336a4")
    add_versions("v1.8.2", "1182cab00c33e400eac617c6dbf44fa2f358e1844990b6b8c5c87783024f9971")
    add_versions("v1.9.1", "0f8bab22e02681d05787c88cbef5d04b105f6644ebf7cf29898d0a52ebe959e4")

    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "trantor.patch"), "7f9034a27bb63de8dedb80dd9f246ea7aa7724c87f2c0d0054f4b6097ea2a862")
    add_patches("1.4.1", path.join(os.scriptdir(), "patches", "1.4.1", "resolv.patch" ), "a1054822bf91f5f06de8bca9b1bd8859233228159a8ff8014ce6329d6c000f26")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "trantor.patch"), "87e317bf5e45b3f3dfe781db8a0af9603ebdab057a6aedbc36d8aec9e0da58a7")
    add_patches("1.6.0", path.join(os.scriptdir(), "patches", "1.6.0", "resolv.patch" ), "dc144ff1cdcfee413efbcdc568fed587318289e8fa1bb0da9d2ea94a15588b25")
    add_patches("1.7.1", path.join(os.scriptdir(), "patches", "1.7.1", "trantor.patch"), "3f93a1e78ba45c8f1e85c28d4fdbbd3e7961078da8cf417a97d8797a91fa2167")
    add_patches("1.7.1", path.join(os.scriptdir(), "patches", "1.7.1", "resolv.patch" ), "75d3618374d15a5ec12681c8659e183f3e620acc43c77ae66e7bea21a25ca546")
    add_patches(">=1.7.3 <1.8.0", path.join(os.scriptdir(), "patches", "1.7.3", "trantor.patch"), "27e479dd0e3f8adc75c9c21fe895937f727c3102e5bfb21ac3289d6ad2795b7a")
    add_patches(">=1.7.3 <1.8.0", path.join(os.scriptdir(), "patches", "1.7.3", "resolv.patch" ), "49694f090e169a5c0e524726e8b85ad0bac76c05ed633c60e986849c2e5adb85")
    add_patches("1.8.0",   path.join(os.scriptdir(), "patches", "1.8.0", "redis.patch" ), "cf09beb4f07fd970ef4ad8911eec71ce7c94609ad9fbf1626b5ca8fcd070e09e")
    add_patches(">=1.8.0 <1.8.4", path.join(os.scriptdir(), "patches", "1.8.0", "resolv.patch"), "e9b6b320c70d17024931be8481f7b6413681216113466b5d6699431bb98d50e2")
    add_patches(">=1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "config.patch"), "67a921899a24c1646be6097943cc2ed8228c40f177493451f011539c6df0ed76")
    add_patches(">=1.8.0", path.join(os.scriptdir(), "patches", "1.8.0", "check.patch"), "e4731995bb754f04e1bb813bfe3dfb480a850fbbd5cdb48d5a53b32b4ed8669c")
    add_patches(">=1.8.2 <1.8.5", path.join(os.scriptdir(), "patches", "1.8.2", "gcc13.patch"), "d2842a734df52c590ab950414c7a95a1ac1be48f8680f909d0eeba5f36087cb0")
    add_patches(">=1.9.1", path.join(os.scriptdir(), "patches", "1.9.1", "resolv.patch"), "2b511e60fe99062396accab6b25d0092e111a83db11cffc23ce8e790370d017c")
    if is_plat("windows") then
        add_patches("1.9.6", path.join(os.scriptdir(), "patches", "1.9.6", "windows-build.patch"), "4a798dc3ba7df2f1541ecf66b1b03bab15f200d310ac63f7893770cb3b199453")
    end
    add_patches("1.9.11", path.join(os.scriptdir(), "patches", "1.9.11", "find-mysql.patch"), "0813b02190dad0bb3e6f524e3f39a8fec1e231153fb91d9869391fd6f2fb91de")

    add_configs("c_ares", {description = "Enable async DNS query support.", default = false, type = "boolean"})
    add_configs("mysql", {description = "Enable mysql support.", default = false, type = "boolean"})
    add_configs("openssl", {description = "Enable openssl support.", default = true, type = "boolean"})
    add_configs("postgresql", {description = "Enable postgresql support.", default = false, type = "boolean"})
    add_configs("sqlite3", {description = "Enable sqlite3 support.", default = false, type = "boolean"})
    add_configs("redis", {description = "Enable redis support.", default = false, type = "boolean"})
    add_configs("yaml", {description = "Enable yaml support.", default = false, type = "boolean"})
    add_configs("spdlog", {description = "Allow using the spdlog logging library", default = false, type = "boolean"})
    add_configs("cpp20", {description = "Enable c++ 20 support.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("jsoncpp", "brotli", "zlib")
    if not is_plat("windows", "mingw", "msys") then
        add_deps("libuuid")
    end

    if is_plat("windows") then
        -- enable mtt for drogon
        set_policy("package.msbuild.multi_tool_task", true)
        add_syslinks("ws2_32", "rpcrt4", "crypt32", "advapi32", "iphlpapi")
    elseif is_plat("mingw") then
        add_syslinks("ws2_32", "rpcrt4", "crypt32", "advapi32", "iphlpapi")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    if on_check then
        on_check("wasm", function (target)
            raise("package(drogon) dep(openssl) unsupported platform")
        end)
    end

    on_load(function(package)
        local configdeps = {c_ares     = "c-ares",
                            mysql      = "mariadb-connector-c",
                            openssl    = "openssl",
                            postgresql = "postgresql",
                            sqlite3    = "sqlite3",
                            redis      = "hiredis",
                            yaml       = "yaml-cpp"}

        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
        if package:version() and package:version():le("v1.9.2") then
            package:config_set("spdlog", false)
        end
        if package:config("spdlog") then
            package:add("defines", "DROGON_SPDLOG_SUPPORT")
            package:add("deps", "trantor", {configs = {spdlog = true}})
        else
            package:add("deps", "trantor")
        end
    end)

    on_install("!android", function (package)
        io.replace("cmake/templates/config.h.in", "\"@COMPILATION_FLAGS@@DROGON_CXX_STANDARD@\"", "R\"(@COMPILATION_FLAGS@@DROGON_CXX_STANDARD@)\"", {plain = true})
        io.replace("cmake_modules/FindMySQL.cmake", "PATH_SUFFIXES mysql", "PATH_SUFFIXES mysql mariadb", {plain = true})

        local trantor = package:dep("trantor")
        if (not trantor:is_system() and not trantor:config("shared")) or package:config("openssl") then
            if package:is_plat("windows", "mingw") then
                io.replace("CMakeLists.txt", "Trantor::Trantor", "Trantor::Trantor ws2_32 user32 crypt32 advapi32", {plain = true})
            end
        end

        local configs = {
            "-DBUILD_EXAMPLES=OFF",
            "-DUSE_SUBMODULE=OFF",
            "-DBUILD_EXAMPLES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DROGON_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_CTL=" .. (package:is_cross() and "OFF" or "ON"))

        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if name == "sqlite3" then
                    table.insert(configs, "-DBUILD_SQLITE=" .. (enabled and "ON" or "OFF"))
                elseif name == "yaml" then
                    if package:version() and package:version():ge("1.8.4") then
                        table.insert(configs, "-DBUILD_YAML_CONFIG=" .. (enabled and "ON" or "OFF"))
                    end
                elseif name == "cpp20" then
                    table.insert(configs, "-DCMAKE_CXX_STANDARD=20")
                else
                    table.insert(configs, "-DBUILD_" .. name:upper() .. "="  .. (enabled and "ON" or "OFF"))
                end
            end
        end

        local openssl = package:dep("openssl")
        if not openssl:is_system() then
            table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
        end

        local opt = {}
        local trantor_version = package:dep("trantor"):version()
        if trantor_version and trantor_version:ge("v1.5.25") then
            opt.cxflags = "-DMICRO_SECONDS_PRE_SEC=1000000"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("drogon::getVersion()", {configs = {languages = "c++17"}, includes = "drogon/drogon.h"}))
    end)
