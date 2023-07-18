package("bdwgc")
    set_homepage("https://www.hboehm.info/gc/")
    set_description("The Boehm-Demers-Weiser conservative C/C++ Garbage Collector (bdwgc, also known as bdw-gc, boehm-gc, libgc)")

    add_urls("https://github.com/ivmai/bdwgc/-/archive/$(version).tar.gz",
             "https://github.com/ivmai/bdwgc.git")

    add_versions("v8.2.4", "18e63ab1428bd52e691da107a6a56651c161210b11fbe22e2aa3c31f7fa00ca5")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs({test=[[
        void test() {
            GC_INIT();
            int *ptr = GC_MALLOC(sizeof(int));
            *ptr = 42;
            printf("Value: %d\n", *ptr);
            return 0;
        }
        ]]}),{configs = {includes = "gc.h"}})
    end)
