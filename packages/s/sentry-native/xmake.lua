package("sentry-native")
    set_homepage("https://sentry.io")
    set_description("Sentry SDK for C, C++ and native applications.")

    set_urls("https://github.com/getsentry/sentry-native/releases/download/$(version)/sentry-native.zip",
             "https://github.com/getsentry/sentry-native.git")

    add_versions("0.7.9", "d01f66125e1fb80c02668d2ea6b908987323d3f477d69332ef21506a62606d40")
    add_versions("0.7.6", "42180ad933a3a2bd86a1649ed0f1a41df20e783ce17c5cb1f86775f7caf06bc1")
    add_versions("0.7.5", "d9f1b44753fae3e9462aa1e6fd3021cb0ff2f51c1a1fa02b34510e3bc311f429")
    add_versions("0.7.2", "afb44d5cc4e0ec5f2e8068132c68256959188f6bf015e1837e7cc687014b9c70")
    add_versions("0.7.1", "c450a064b0dbb1883a355455db2b6469abef59c04686a53719384bbc7ff507d3")
    add_versions("0.7.0", "4dfccc879a81771b9da1c335947ffc9e5987ca3d16b3035efa2c66a06f727543")
    add_versions("0.6.7", "37d7880f837c85d0b19cac106b631c7b4524ff13f11cd31e8337da10842ea779")
    add_versions("0.6.6", "7a98467c0b2571380a3afc5e681cb13aa406a709529be12d74610b0015ccde0c")
    add_versions("0.6.5", "5f74a5c5c3abc6e1e7825d3306be9e3b3fd4e0f586f3cf7e86607d6f56a71995")
    add_versions("0.6.4", "e00278bf9a4821bb4008985a5a552a84aba6ebb06d3f9e828082fcbf06b04a38")
    add_versions("0.6.3", "6b515c17a9b860ea47c6a5fd7abdfdc89b4b8cbc654c23a8bb42a39bfcb87ad9")
    add_versions("0.5.0", "87e67ad783a7ec4476b0eb4742bd40fe5a1e2435")
    add_versions("0.4.15", "ae3ac4efa76d431d8734d7b0b1bf9bbedaf2cbdb18dfc5c95e2411a67808cf29")
    add_versions("0.4.4", "fe6c711d42861e66e53bfd7ee0b2b226027c64446857f0d1bbb239ca824a3d8d")
    add_patches("0.4.4", path.join(os.scriptdir(), "patches", "0.4.4", "zlib_fix.patch"), "1a6ac711b7824112a9062ec1716a316facce5055498d1f87090d2cad031b865b")

    add_deps("cmake")

    add_configs("backend", {description = "Set the backend of sentry to use", type = "string"})

    if is_plat("windows") then
        add_syslinks("dbghelp", "winhttp", "shlwapi", "advapi32", "version")
    elseif is_plat("linux") then
        add_deps("libcurl")
        add_syslinks("dl", "pthread", "rt")
    elseif is_plat("android") then
        add_syslinks("dl", "log")
    elseif is_plat("macosx") then
        add_deps("libcurl")
        add_frameworks("CoreText", "CoreGraphics", "SystemConfiguration", "CoreFoundation", "Foundation")
        add_syslinks("bsm")
    end

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ranges>
            template<typename T>
            concept CR = std::ranges::contiguous_range<T>;
            void test() {}
        ]]}, {configs = {languages = "c++20"}}), "package(sentry-native) Require at least C++20.")
    end)

    on_load("windows", "linux", "macosx", function (package)
        if not package:config("shared") then
            package:add("defines", "SENTRY_BUILD_STATIC")
        end

        local backend
        if package:is_plat("linux") then -- linux defaults to breakpad before 0.7 and then defaults to crashpad
            backend = package:version() and package:version():ge("0.7") and "crashpad" or "breakpad"
        end
        if package:config("backend") == "crashpad" then
            backend = "crashpad"
        elseif package:config("backend") == "breakpad" then
            backend = "breakpad"
        end

        if backend == "crashpad" then
            package:add("links", "sentry", "crashpad_client", "crashpad_util", "crashpad_minidump", "crashpad_handler_lib", "mini_chromium", "crashpad_tools", "crashpad_compat", "crashpad_snapshot")
            package:add("deps", "zlib")
        elseif backend == "breadpad" then
            package:add("links", "sentry", "breakpad_client")
        end
    end)

    on_install("windows|x86", "windows|x64", "linux", "macosx|x86_64", function (package) -- TODO: to enable android you will need to figure out the order of libs
        local opt = {}
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
        if package:config("backend") then
            table.insert(configs, "-DSENTRY_BACKEND=" .. package:config("backend"))
        end
        if package:is_plat("windows") then
            opt.cxflags = { "/experimental:preprocessor-" } -- fixes <Windows SDK>\um\oaidl.h(487): error C2059: syntax error: '/'
            local vs_runtime = package:config("vs_runtime")
            table.insert(configs, "-DSENTRY_BUILD_RUNTIMESTATIC=" .. ((vs_runtime == "MT" or vs_runtime == "MTd") and "ON" or "OFF"))
        elseif package:is_plat("macosx") then
            opt.shflags = {"-framework", "SystemConfiguration"}
        end
        import("package.tools.cmake").install(package, configs, opt)
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
