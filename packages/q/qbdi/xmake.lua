package("qbdi")
    set_homepage("https://qbdi.quarkslab.com")
    set_description("A Dynamic Binary Instrumentation framework based on LLVM.")
    set_license("Apache-2.0")

    add_urls("https://github.com/QBDI/QBDI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/QBDI/QBDI.git")

    add_versions("v0.12.0", "2b918fec3424ac9667796c1a5e216d0fbe57e83da92123e15411d9ea43b30a5b")

    add_configs("avx", {description = "Enable the support of AVX instruction on X86 and X86_64.", default = true, type = "boolean"})
    add_configs("log_debug", {description = "Enable the debug level of the logging system.", default = false, type = "boolean"})

    add_deps("cmake", "ninja")
    on_load(function (package)
        package:add("links", "QBDI")
    end)

    on_install("linux", "android", "iphoneos", "macosx", "windows", function (package)
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
        assert(qbdi_architectures[package:arch()], "package(qbdi): unsupported architecture!")

        local configs = {
            "-DBUILD_SHARED_LIBS=OFF",
            "-DQBDI_CCACHE=OFF",
            "-DQBDI_TEST=OFF",
            "-DQBDI_TOOLS_PYQBDI=OFF",
            "-DQBDI_TOOLS_FRIDAQBDI=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DQBDI_PLATFORM=" .. qbdi_platforms[package:plat()])
        table.insert(configs, "-DQBDI_ARCH=" .. qbdi_architectures[package:arch()])
        table.insert(configs, "-DQBDI_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DQBDI_SHARED_LIBRARY=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DQBDI_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DQBDI_DISABLE_AVX=" .. (package:config("avx") and "OFF" or "ON"))
        table.insert(configs, "-DQBDI_LOG_DEBUG=" .. (package:config("log_debug") and "ON" or "OFF"))

        if package:config("shared") then
            table.insert(configs, "-DQBDI_TOOLS_QBDIPRELOAD=OFF")
            table.insert(configs, "-DQBDI_TOOLS_VALIDATOR=OFF")
        end

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
