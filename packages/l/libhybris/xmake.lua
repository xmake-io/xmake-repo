package("libhybris")
    set_homepage("https://github.com/libhybris/libhybris")
    set_description("Hybris is a solution that commits hybris, by allowing us to use bionic-based HW adaptations in glibc systems ")

    add_urls("https://github.com/libhybris/libhybris.git")
    add_versions("2024.09.01", "936279916605003fba95a0f3629a6bc5e6caa343")

    add_deps("autoconf", "automake", "libtool", "pkg-config")
    add_deps("android", {configs = {
        ["platform/bionic"] = true,
        ["platform/hardware/libhardware"] = true,
        ["platform/hardware/libhardware_legacy"] = true,
        ["platform/frameworks/opt/net/wifi"] = true,
        ["platform/system/core"] = true,
        ["platform/system/media"] = true,
        ["platform/frameworks/native"] = true,
        ["platform/external/kernel-headers"] = true,
    }})

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        table.insert(configs, "--enable-arch=x86")
        table.insert(configs, "--with-android-headers=" .. package:dep("android"):installdir())
        os.cd("hybris")
        io.replace("configure.ac", "AC_INIT([libhybris], [0.1.0])", "AC_INIT([libhybris], [0.1.0])\nAC_CONFIG_MACRO_DIRS([m4])", {plain = true})
        os.vrun("autoupdate")
        os.vrun("aclocal")
        os.vrun("libtoolize")
        os.vrunv("autoreconf", {"--install"})
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                void* handle = hybris_dlopen("libc.so", RTLD_LAZY);
                hybris_dlclose(handle);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "hybris/common/binding.h"}))
    end)
