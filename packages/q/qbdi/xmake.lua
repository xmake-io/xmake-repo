package("qbdi")
    set_homepage("https://qbdi.quarkslab.com")
    set_description("A Dynamic Binary Instrumentation framework based on LLVM.")
    set_license("Apache-2.0")

    add_urls("https://github.com/QBDI/QBDI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/QBDI/QBDI.git")

    add_versions("v0.12.1", "6c530f55285282cbf5b3ad569013c6db9751c4ce7f3d33eb6aa39df48e7abd45")
    add_versions("v0.12.0", "2b918fec3424ac9667796c1a5e216d0fbe57e83da92123e15411d9ea43b30a5b")

    add_configs("avx", {description = "Enable the support of AVX instruction on X86 and X86_64.", default = true, type = "boolean"})
    add_configs("log_debug", {description = "Enable the debug level of the logging system.", default = false, type = "boolean"})
    if is_plat("android", "iphoneos") then
        add_configs("preload", {description = "Build QBDIPreload static library.", default = false, type = "boolean", readonly  = true})
        add_configs("validator", {description = "Build the validator library.", default = false, type = "boolean", readonly  = true})
    else
        add_configs("preload", {description = "Build QBDIPreload static library.", default = true, type = "boolean"})
        add_configs("validator", {description = "Build the validator library.", default = true, type = "boolean"})
    end

    add_patches(">=0.12.0", "patches/v0.12.0/unbundle-spdlog.patch", "cfe99819dcf2007a491aca5861122e6ea4b1419a4ee4028f4227c9ef7a54748d")

    add_patches("v0.12.0", "patches/v0.12.0/explicitly-use-non-executable-stack.patch", "a2628cd1f0c92cc8ef67c13d944a397d9aee21abce5e382e73f2a168497b8625")
    add_patches("v0.12.0", "patches/v0.12.0/set-llvm-host-triple.patch", "47df87484ed9403e31e5e83859e6e1d5fdb5a353631948fda008f11282932891")
    add_patches("v0.12.0", "patches/v0.12.0/fix-build-android-x86-64.patch", "69cc15efa38fd36547d4f5261a5e1aac6dd02aa183e2c13552dbce140ef4ad2f")

    local qbdi_platforms = {
        linux = "linux",
        android = "android",
        iphoneos = "ios",
        macosx = "osx",
        windows = "windows"
    }

    local qbdi_architectures = {
        x86_64 = "X86_64",
        x64 = "X86_64",
        i386 = "X86",
        x86 = "X86",
        arm64 = "AARCH64",
        ["arm64-v8a"] = "AARCH64",
        arm = "ARM",
        armv7 = "ARM",
        armv7s = "ARM",
        ["armeabi-v7a"] = "ARM"
    }

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("spdlog", {configs = {header_only = false, noexcept = true, tls = false, thread_id = false}})
    add_deps("cmake", "python 3.x", {kind = "binary"})

    on_check(function (package)
        assert(qbdi_architectures[package:arch()], "package(qbdi): unsupported architecture!")
    end)

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("links", package:config("shared") and "QBDI" or "QBDI_static")
        else
            package:add("links", "QBDI")
        end
        if package:is_plat("android") then
            package:add("syslinks", "log")
        end
        if package:config("shared") then
            package:config_set("preload", false)
            package:config_set("validator", false)
        end
        if not package:config("preload") and package:config("validator") then
            package:config_set("preload", true)
        end
    end)

    on_install("linux", "android", "iphoneos", "macosx", "windows|!arm*", function (package)
        local configs = {
            "-DBUILD_SHARED_LIBS=OFF",
            "-DQBDI_CCACHE=OFF",
            "-DQBDI_TEST=OFF",
            "-DQBDI_TOOLS_PYQBDI=OFF",
            "-DQBDI_TOOLS_FRIDAQBDI=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DQBDI_PLATFORM=" .. qbdi_platforms[package:plat()])
        table.insert(configs, "-DQBDI_ARCH=" .. qbdi_architectures[package:arch()])
        table.insert(configs, "-DQBDI_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DQBDI_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DQBDI_ASAN=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DQBDI_DISABLE_AVX=" .. (package:config("avx") and "OFF" or "ON"))
        table.insert(configs, "-DQBDI_LOG_DEBUG=" .. (package:config("log_debug") and "ON" or "OFF"))
        table.insert(configs, "-DQBDI_TOOLS_QBDIPRELOAD=" .. (package:config("preload") and "ON" or "OFF"))
        table.insert(configs, "-DQBDI_TOOLS_VALIDATOR=" .. (package:config("validator") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                uint32_t version;
                QBDI::getVersion(&version);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "QBDI.h"}))
    end)
