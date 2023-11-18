package("libco")
    set_homepage("https://github.com/Tencent/libco")
    set_description("Libco is a c/c++ coroutine library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/Tencent/libco.git")
    add_versions("v1.0", "dc6aafcc5e643d3b454a58acdc78e223634bbd1e")
    
    add_syslinks("pthread")
    
    on_install("linux", function (package)
        local configs = {}
        import("package.tools.make").make(package, configs)
        if package:config("shared") then
            os.trycp("**.so", package:installdir("lib"))
        else
            os.trycp("**.a", package:installdir("lib"))
        end
    
        os.cp("**.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int loop(void *)
            {
                return 0;
            }
            static void *routine_func(void *)
            {
                stCoEpoll_t * ev = co_get_epoll_ct();
                co_eventloop( ev, loop, 0 );
                return 0;
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"co_routine.h","co_routine_inner.h"}}))
    end)
