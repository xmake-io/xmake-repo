package("sentry-native")

    set_homepage("https://sentry.io")
    set_description("Sentry SDK for C, C++ and native applications.")

    set_urls("https://github.com/getsentry/sentry-native/releases/download/$(version)/sentry-native.zip",
             "https://github.com/getsentry/sentry-native.git")

    add_versions("0.4.4", "fe6c711d42861e66e53bfd7ee0b2b226027c64446857f0d1bbb239ca824a3d8d")
    add_patches("0.4.4", path.join(os.scriptdir(), "patches", "0.4.4", "zlib_fix.patch"), "1a6ac711b7824112a9062ec1716a316facce5055498d1f87090d2cad031b865b")

    add_deps("cmake")

    on_load("linux", "macos", "iphoneos", "android", "cross", function (package)
        package:add("deps", "libcurl")
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DSENTRY_BUILD_EXAMPLES=OFF")
        table.insert(configs, "-DSENTRY_BUILD_TESTS=OFF")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DSENTRY_BUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            table.insert(configs, "-DSENTRY_BUILD_SHARED_LIBS=OFF")
        end
        if package:is_plat("windows") then
            local vs_runtime = package:config("vs_runtime")
            table.insert(configs, "-SENTRY_BUILD_RUNTIMESTATIC=" .. ((vs_runtime == "MT" or vs_runtime == "MTd") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                sentry_options_t* options = sentry_options_new();
                sentry_init(options);
                sentry_shutdown();
            }
        ]]}, {includes = {"sentry.h"}}))
    end)
