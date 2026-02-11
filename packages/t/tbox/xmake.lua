package("tbox")

    set_homepage("https://tboox.org")
    set_description("A glib-like multi-platform c library")

    add_urls("https://github.com/tboox/tbox/archive/$(version).tar.gz")
    add_urls("https://github.com/tboox/tbox.git")
    add_urls("https://gitlab.com/tboox/tbox.git")
    add_urls("https://gitee.com/tboox/tbox.git")

    add_versions("v1.6.2", "26ede7fd61e33c3635bf2d6657ae4040a4a75c82a5da88855fd965db2f834025")
    add_versions("v1.6.3", "1ea225195ad6d41a29389137683fee7a853fa42f3292226ddcb6d6d862f5b33c")
    add_versions("v1.6.4", "07747a3704a2f3937debf0e666ffca368c4cb427008a52641782c0d8b7821886")
    add_versions("v1.6.5", "076599f8699a21934f633f1732977d0df9181891ca982fd23ba172047d2cf4ab")
    add_versions("v1.6.6", "13b8fa0b10c2c0ca256878a9c71ed2880980659dffaadd123c079c2126d64548")
    add_versions("v1.6.7", "7bedfc46036f0bb99d4d81b5a344fa8c24ada2372029b6cbe0c2c475469b2b70")
    add_versions("v1.6.9", "31db6cc51af7db76ad5b5da88356982b1e0f1e624c466c749646dd203b68adae")
    add_versions("v1.7.1", "236493a71ffc9d07111e906fc2630893b88d32c0a5fbb53cd94211f031bd65a1")
    add_versions("v1.7.4", "c2eb29ad0cab15b851ab54cea6ae99555222a337a0f83340ae820b4a6e76a10c")
    add_versions("v1.7.5", "6382cf7d6110cbe6f29e8346d0e4eb078dd2cbf7e62913b96065848e351eb15e")
    add_versions("v1.7.6", "2622de5473b8f2e94b800b86ff6ef4a535bc138c61c940c3ab84737bb94a126a")

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
        add_syslinks("ws2_32", "user32", "kernel32")
    elseif is_plat("mingw") then
        add_syslinks("ws2_32", "pthread")
    elseif is_plat("macosx", "iphoneos") then
        add_frameworks("Foundation", "CoreServices", "CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread", "m", "dl")
    elseif is_plat("bsd") then
        add_syslinks("execinfo", "pthread", "m", "dl")
    elseif not is_plat("android") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:debug() then
            package:add("defines", "__tb_debug__")
        end
        for _, dep in ipairs({"mbedtls", "openssl", "sqlite3", "pcre2", "pcre", "mysql", "zlib"}) do
            if package:config(dep) then
                package:add("deps", dep)
            end
        end
    end)

    on_install(function (package)
        local configs = {demo = false}
        if package:config("micro") then
            configs.micro = true
        end
        if not package:config("float") then
            configs["float"] = false
        end
        if package:config("force-utf8") then
            configs["force-utf8"] = true
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
        if package:has_tool("cc", "cosmocc") then
            os.trycp(path.join(package:builddir(), "**", ".aarch64"), package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tb_exit", {includes = "tbox/tbox.h", configs = {languages = "c99"}}))
    end)
