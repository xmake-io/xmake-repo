package("platformfolders")
    set_homepage("https://github.com/sago007/PlatformFolders")
    set_description([[A C++ library to look for special directories like "My Documents" and "%APPDATA%" so that you do not need to write Linux, Windows or Mac OS X specific code]])
    set_license("MIT")

    add_urls("https://github.com/sago007/PlatformFolders/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sago007/PlatformFolders.git")

    add_versions("4.3.0", "4d1c3139882c55f4f1206d89157a699224476e17fbeda68d891ddfb61f901ffd")
    add_versions("4.2.0", "31bb0f64a27315aec8994f226332aaafe9888d00bb69a2ff2dff9912e2f4ccf4")

    add_patches(">=4.2.0", "patches/4.2.0/cmake-install.patch", "a38850ff7e9b91034f226685af7633ff692de3aea4798cb3dddecc6b055a7601")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("ole32", "shell32", "uuid")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DPLATFORMFOLDERS_BUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                sago::getConfigHome();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "sago/platform_folders.h"}))
    end)
