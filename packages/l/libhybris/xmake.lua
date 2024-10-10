package("libhybris")
    set_homepage("https://github.com/libhybris/libhybris")
    set_description("Hybris is a solution that commits hybris, by allowing us to use bionic-based HW adaptations in glibc systems ")

    add_urls("https://github.com/libhybris/libhybris.git")
    add_versions("2024.09.01", "936279916605003fba95a0f3629a6bc5e6caa343")

    add_deps("autoconf", "automake", "libtool", "pkgconf", "ndk")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        local ndk_version = package:dep("ndk"):version()
        local ndk_version_major = ndk_version:major() or 0
        local ndk_version_minor = ndk_version:minor() or 0
        local ndk_version_patch = ndk_version:patch() or 0
        os.run(
            "sh utils/extract-headers.sh --version %s %s %s", 
            ndk_version_major .. '.' .. ndk_version_minor .. '.' .. ndk_version_patch,
            package:dep("ndk"):installdir(),
            package:installdir("include")
        )
        os.cd("hybris")
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
