package("nativefiledialog-extended")

    set_homepage("https://github.com/btzy/nativefiledialog-extended")
    set_description("Cross platform (Windows, Mac, Linux) native file dialog library with C and C++ bindings, based on mlabbe/nativefiledialog.")
    
    add_urls("https://github.com/btzy/nativefiledialog-extended/archive/refs/tags/$(version).zip",
             "https://github.com/btzy/nativefiledialog-extended.git")
    add_versions("v1.0.2", "1d2c4c50fb1e3ad8caa5ad9c3df54725c3a49a6d4a21d773a20b93ebeb5780f1")

    add_configs("portal", {description = "Use xdg-desktop-portal instead of GTK.", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("shell32", "ole32")
    elseif is_plat("macosx") then
        add_frameworks("AppKit", "UniformTypeIdentifiers")
    end
    on_load("linux", function (package)
        if package:config("portal") then
            package:add("deps", "dbus")
        else
            package:add("deps", "gtk+3")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DNFD_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNFD_PORTAL=" .. (package:config("portal") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                NFD_Init();
                nfdchar_t *outPath = NULL;
                nfdfilteritem_t filterItem[2] = {{"Source code", "c,cpp,cc"}, {"Headers", "h,hpp"}};
                nfdresult_t result = NFD_OpenDialog(&outPath, filterItem, 2, NULL);
                NFD_Quit();
            }
        ]]}, {includes = "nfd.h"}))
    end)
