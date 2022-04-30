package("minizip-ng")

    set_homepage("https://github.com/zlib-ng/minizip-ng")
    set_description("Fork of the popular zip manipulation library found in the zlib distribution.")
    set_license("zlib")

    add_urls("https://github.com/zlib-ng/minizip-ng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zlib-ng/minizip-ng.git")
    add_versions("3.0.3", "5f1dd0d38adbe9785cb9c4e6e47738c109d73a0afa86e58c4025ce3e2cc504ed")
    add_versions("3.0.5", "1a248c378fdf4ef6c517024bb65577603d5146cffaebe81900bec9c0a5035d4d")

    add_configs("zlib",  {description = "Enable zlib compression library.", default = true, type = "boolean"})
    add_configs("lzma",  {description = "Enable liblzma compression library.", default = false, type = "boolean"})
    add_configs("bzip2", {description = "Enable bzip2 comppressression library.", default = false, type = "boolean"})
    add_configs("zstd",  {description = "Enable zstd comppressression library.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "Security")
        add_syslinks("iconv")
    elseif is_plat("linux", "android") then
        add_deps("openssl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("crypt32", "advapi32")
    end

    on_load(function (package)
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    package:add("deps", name)
                end
            end
        end
    end)

    on_install("macosx", "android", "linux", "windows", "mingw", function (package)
        local configs = {"-DMZ_LIBCOMP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DMZ_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("zipOpen", {includes = {"mz.h", "mz_compat.h"}}))
    end)
