package("efsw")
    set_homepage("https://github.com/SpartanJ/efsw")
    set_description("efsw is a C++ cross-platform file system watcher and notifier.")
    set_license("MIT")

    set_urls("https://github.com/SpartanJ/efsw/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SpartanJ/efsw.git")
    add_versions("1.5.1", "403691e15b48dc0e67e7d3fe6e6aa3d116bc8420790df93d1d90d2cecaa06e70")
    add_versions("1.5.0", "20421778fd59a845393ff6a7a1f461228574fe5062b1bf5f82d533c0d25a41bd")
    add_versions("1.4.1", "f0ddee587928737c6a3dc92eb88266a804c77279cbdf29d47e5e6f6ad6c7fd9a")
    add_versions("1.4.0", "9eed5fc8471767faa44134f5379d4de02825e3756007dafa482fd1656e42bc4a")
    add_versions("1.3.1", "3c0efe023258712d25644977227f07cf7edf7e5dc00ffa8d88733f424fa6af86")
    add_versions("1.3.0", "e190b72f23d92c42e1a0dab9bb6354a56f75c7535fd1f3e3a10b1c317e05f8f6")
    add_versions("1.2.0", "66d8631deeb2af50511e84cae7e745134e6a22811c93246e39e7001af887a7db")
    add_versions("1.1.0", "a67566d642510e3f571cc0f98d520bd806150362a51cfbc47366ed6c9890722f")

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices")
    end

    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "EFSW_DYNAMIC")
        end
    end)

    on_install("windows", "linux", "mingw", "macosx", "bsd", "iphoneos", function (package)
        local configs = {"-DBUILD_TEST_APP=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            class CustomListener : public efsw::FileWatchListener {
                void handleFileAction(efsw::WatchID watchid, const std::string& dir, const std::string& filename, efsw::Action action, std::string oldFilename) {}
            };

            void test() {
                CustomListener customListener;

                efsw::FileWatcher fileWatcher;
                fileWatcher.addWatch(".", &customListener);
            }
        ]]}, {includes = {"efsw/efsw.hpp"}}))
    end)
