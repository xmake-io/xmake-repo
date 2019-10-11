package("tbox")

    set_homepage("http://www.tboox.org")
    set_description("A glib-like multi-platform c library")

    add_urls("https://github.com/tboox/tbox/archive/$(version).tar.gz")
    add_urls("https://github.com/tboox/tbox.git")
    add_urls("https://gitlab.com/tboox/tbox.git")
    add_urls("https://gitee.com/tboox/tbox.git")

    add_versions("v1.6.2", "26ede7fd61e33c3635bf2d6657ae4040a4a75c82a5da88855fd965db2f834025")
    add_versions("v1.6.3", "1ea225195ad6d41a29389137683fee7a853fa42f3292226ddcb6d6d862f5b33c")
    add_versions("v1.6.4", "eb5d25c64dcfdf2ca7723f74f8252412b74d6ada4ba278664d54e271545ae330")

    add_configs("micro",      {description = "Compile micro core library for the embed system.", default = false, type = "boolean"})
    add_configs("float",      {description = "Enable or disable the float type.", default = true, type = "boolean"})
    add_configs("force-utf8", {description = "Forcely regard all tb_char* as utf-8.", default = false, type = "boolean"})
    for _, name in ipairs({"xml", "zip", "hash", "regex", "object", "charset", "database", "coroutine"}) do
        add_configs(name, {description = "Enable the " .. name .. " module.", default = false, type = "boolean"})
    end
    for _, name in ipairs({"zlib", "mysql", "sqlite3", "openssl", "polarssl", "mbedtls", "pcre2", "pcre"}) do
        add_configs(name, {description = "Enable the " .. name .. " package.", default = false, type = "boolean"})
    end

    if is_plat("windows") then
        add_syslinks("ws2_32")
    elseif is_plat("mingw") then
        add_syslinks("ws2_32", "pthread")
    elseif not is_plat("android") then
        add_syslinks("pthread")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("Foundation")
    end

    on_load(function (package) 
        if package:debug() then
            package:add("defines", "__tb_debug__")
        end
    end)
 
    on_install(function (package)
        local configs = {demo = false}
        if package:config("micro") then
            config.micro = true
        end
        if not package:config("float") then
            config["float"] = false
        end
        if package:config("force-utf8") then
            config["force-utf8"] = true
        end
        for _, name in ipairs({"xml", "zip", "hash", "regex", "object", "charset", "database", "coroutine"}) do
            if package:config(name) then
                configs[name] = true
            end
        end
        for _, name in ipairs({"zlib", "mysql", "sqlite3", "openssl", "polarssl", "mbedtls", "pcre2", "pcre"}) do
            if package:config(name) then
                configs[name] = true
            end
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tb_exit", {includes = "tbox/tbox.h"}))
    end)
