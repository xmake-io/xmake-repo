package("co")

    set_homepage("https://github.com/idealvin/co")
    set_description("Yet another libco and more.")
 
    add_urls("https://github.com/idealvin/co.git")
 
    on_install("macosx", "linux", "windows", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "co/def.h"
            #include "co/atomic.h"
            void test() {
                int32 i32 = 0;
                atomic_inc(&i32);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
