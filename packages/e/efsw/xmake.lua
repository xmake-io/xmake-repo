package("efsw")
    set_homepage("https://github.com/SpartanJ/efsw")
    set_description("efsw is a C++ cross-platform file system watcher and notifier.")
    set_license("MIT")

    set_urls("https://github.com/SpartanJ/efsw/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SpartanJ/efsw.git")
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

    on_install("windows", "linux", "mingw", "macosx", "bsd", function (package)
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
