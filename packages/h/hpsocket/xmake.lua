package("hpsocket")
    set_homepage("https://github.com/ldcsaa/HP-Socket")
    set_description("High Performance Network Framework")
    set_license("Apache-2.0")

    add_urls("https://github.com/ldcsaa/HP-Socket/archive/$(version).tar.gz",
             "https://github.com/ldcsaa/HP-Socket.git")
    add_versions("v5.7.3", "e653f3c15ded3a4b622ab9a4a52a477c7aa40f5b86398c6b75f5a732a55496a0")
    add_versions("v5.8.4", "6fd207b84e41174c06d27c0df7244584eb07fbac0a7e49d7429103071184a451")
    add_versions("v5.9.1", "d40a3d0b4f0d2773ae61d32ed95df655aa6ccf5ae22c40ef38bfc88882b2478b")

    local configs = {{name = "udp",    package = "kcp"},
                     {name = "http",   package = "http_parser"},
                     {name = "zlib",   package = is_plat("android", "windows") and "" or "zlib"},
                     {name = "brotli", package = "brotli"},
                     {name = "ssl",    package = ""},
                     {name = "iconv",  package = ""}}

    for _, cfg in ipairs(configs) do
        local cfg_name = "no_" .. cfg.name
        add_configs(cfg_name, {description = "Build hpsocket without " .. cfg.name, default = false, type = "boolean"})
    end
    add_configs("no_4c",   {description = "Build hpsocket without C interface", default = true, type = "boolean"})
    add_configs("unicode", {description = "Build hpsocket with unicode character set", default = false, type = "boolean"})

    on_load(function (package)
        for _, cfg in ipairs(configs) do
            local cfg_name = "no_" .. cfg.name
            if not package:config(cfg_name) then
                if cfg.package ~= "" then
                    package:add("deps", cfg.package, package:is_plat("windows") and {} or {configs = {cxflags = "-fpic"}})
                end
            else
                package:add("defines", "_" .. string.upper(cfg.name) .. "_DISABLED")
            end
        end

        if package:is_plat("windows") then
            if not package:config("shared") then
                package:add("defines", "HPSOCKET_STATIC_LIB")
            end
            package:add("syslinks", "ws2_32", "user32", "kernel32")
            if not package:config("no_ssl") then
                package:add("syslinks", "crypt32")
            end
        elseif package:is_plat("linux") then
            package:add("syslinks", "pthread", "dl", "rt")
        elseif package:is_plat("android") then
            package:add("syslinks", "dl")
            if not package:config("no_zlib") then
                package:add("syslinks", "z")
            end
        end

        package:add("links", package:config("no_4c") and "hpsocket" or "hpsocket4c")
        if not package:config("shared") then
            if not package:config("no_ssl") then
                local prefix = package:is_plat("windows") and "lib" or ""
                package:add("links", prefix .. "ssl", prefix .. "crypto")
            end
            if not package:config("no_iconv") then
                if package:is_plat("android") then
                    package:add("links", "iconv", "charset")
                end
            end
            if package:is_plat("linux") then
                package:add("links", "jemalloc_pic")
            end
        end
    end)

    on_install("windows|x64", "windows|x86", "linux", "android", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")

        local config = {}
        config.hpversion = package:version()
        config.no_4c = package:config("no_4c")
        config.unicode = package:config("unicode")
        for _, cfg in ipairs(configs) do
            local cfg_name = "no_" .. cfg.name
            if package:config(cfg_name) then
                config[cfg_name] = true
            end
        end
        if package:config("shared") then
            config.kind = "shared"
        end
        import("package.tools.xmake").install(package, config)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            static void test() {
                std::cout << HP_GetHPSocketVersion() << "\n";
            }
        ]]}, {configs = {languages = "c++11"}, includes = package:config("no_4c") and "HPSocket.h" or "HPSocket4C.h"}))
    end)