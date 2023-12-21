package("libmill")
    set_homepage("http://libmill.org")
    set_description("Go-style concurrency in C")

    set_urls("https://github.com/sustrik/libmill.git")

    add_versions("2021.9.9", "e8937e624757663f5379018cae3f2b3e916afb6c")

    add_deps("cmake")

    on_install("macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_PERF=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"), "*.so"))
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include "libmill.h"
            static coroutine void switchtask(size_t count) {
                yield();
            }
            void test() {
                go(switchtask(0));
            }
        ]]}))
    end)
