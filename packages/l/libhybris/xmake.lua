package("libhybris")
    set_homepage("https://github.com/libhybris/libhybris")
    set_description("Hybris is a solution that commits hybris, by allowing us to use bionic-based HW adaptations in glibc systems ")

    add_urls("https://github.com/libhybris/libhybris.git")
    add_versions("2024.09.01", "936279916605003fba95a0f3629a6bc5e6caa343")

    add_deps("autoconf", "automake", "libtool")

    on_install("linux", function (package)
        os.cd("hybris")
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
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
