package("gmssl")
    set_homepage("http://gmssl.org")
    set_description("支持国密SM2/SM3/SM4/SM9/SSL的密码工具箱")
    set_license("Apache-2.0")

    add_urls("https://github.com/guanzhi/GmSSL/archive/refs/tags/$(version).tar.gz",
             "https://github.com/guanzhi/GmSSL.git")

    add_versions("v3.1.0", "a3cdf5df87b07df33cb9e30c35de658fd0c06d5909d4428f4abd181d02567cde")

    if is_plat("mingw", "msys") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32")
    elseif is_plat("linux") then
        add_syslinks("dl")
    elseif is_plat("macosx") then
        add_frameworks("Security")
    end

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("windows") then
            local cflags = table.wrap(package:config("cflags"))
            table.insert(cflags, "/utf-8")
            table.insert(cflags, "-DWIN32")
            package:config_set("cflags", cflags)
            package:add("defines", "WIN32")
            io.replace("CMakeLists.txt", [[set(CMAKE_INSTALL_PREFIX "C:/Program Files/GmSSL")]], "", {plain = true})
        end

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("base64_encode_init", {includes = "gmssl/base64.h"}))
    end)
