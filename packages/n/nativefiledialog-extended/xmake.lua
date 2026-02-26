package("nativefiledialog-extended")
    set_homepage("https://github.com/btzy/nativefiledialog-extended")
    set_description("Cross platform (Windows, Mac, Linux) native file dialog library with C and C++ bindings, based on mlabbe/nativefiledialog.")
    set_license("zlib")

    add_urls("https://github.com/btzy/nativefiledialog-extended/archive/refs/tags/$(version).zip",
             "https://github.com/btzy/nativefiledialog-extended.git")

    add_versions("v1.3.0", "d865b7bf4363fa6aac095b6cfb3b29912054306a18c8c596328fb2e9141c5391")
    add_versions("v1.2.1", "fc359b212e56011931b90bf4241057eddec45308bb4d8b9aab4dfb2f70e3b211")
    add_versions("v1.2.0", "27dc13320816392d0d9905c60645aa684784c7c2559d656b504021edd40f07ed")
    add_versions("v1.1.1", "7003001d36235db2c2062cd992e61c59c77a5ad3ca5e5ed8175e56502513886e")
    add_versions("v1.1.0", "5827d17b6bddc8881406013f419c534e8459b38f34c2f266d9c1da8a7a7464bc")
    add_versions("v1.0.2", "1d2c4c50fb1e3ad8caa5ad9c3df54725c3a49a6d4a21d773a20b93ebeb5780f1")

    add_configs("portal", {description = "Use xdg-desktop-portal instead of GTK.", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("windows", "mingw", "msys") then
        add_syslinks("shell32", "ole32", "uuid")
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

    on_install("windows", "macosx", "linux", "mingw", "msys", function (package)
        local configs = {"-DNFD_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
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
