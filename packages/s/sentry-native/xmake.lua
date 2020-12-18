package("sentry-native")

    set_homepage("https://sentry.io")
    set_description("Sentry SDK for C, C++ and native applications.")

    set_urls("https://github.com/getsentry/sentry-native/archive/$(version).tar.gz",
             "https://github.com/getsentry/sentry-native.git")

    add_versions("0.4.4", "2a5917a4193a7412f5b55fe122c39032f087ae437a4183054a57b2c6b9465f63")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            sentry_options_t* options = sentry_options_new();
            sentry_init(options);
            sentry_shutdown();
        ]]}, {includes = {"sentry.h"}}))
    end)
