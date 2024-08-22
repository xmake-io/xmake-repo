package("cpp-async")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/cpp-async")
    set_description("Support types and functions for C++20 coroutines")
    set_license("MIT")

    add_urls("https://github.com/microsoft/cpp-async/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/cpp-async.git")

    add_versions("v1.1.0", "168681dfd999b7546d623f20d18072ce280502cf0bf3a829c2aec58741062a23")

    on_check(function (package)
        assert(package:has_cxxincludes("coroutine", {configs = {languages = "c++20"}}), "package(cpp-async) Require at least C++20.")
    end)

    on_install(function (package)
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
