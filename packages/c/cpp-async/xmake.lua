package("cpp-async")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/cpp-async")
    set_description("Support types and functions for C++20 coroutines")
    set_license("MIT")

    add_urls("https://github.com/microsoft/cpp-async.git")
    add_versions("v1.1.0", "67907d193f4df024b057caef06ee67fbc0a799c7")

    on_install("windows", "linux", "macosx", "mingw", "msys", "android", "iphoneos", "cross", function (package)
        os.cp("include/async", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <async/task.h>
            #include <coroutine>

            inline async::task<void> do_async()
            {
                co_return;
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
