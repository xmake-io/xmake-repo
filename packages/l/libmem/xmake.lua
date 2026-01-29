package("libmem")
    set_homepage("https://github.com/rdbo/libmem")
    set_description("Cross-platform game hacking library for C, C++, Rust, and Python, supporting process/memory hacking, hooking, detouring, and DLL/SO injection.")
    set_license("AGPL-3.0")

    add_urls("https://github.com/rdbo/libmem/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rdbo/libmem.git", {submodules = false})

    add_versions("5.1.5", "58a1db4f4b01e452c91c307d4486d5e4e39887ee3b3b2ad930b6718d8daeb509")
    add_versions("5.1.4", "68dff11923d515acda091c868a1d5d70596e10c3f106c1ddfee7e329ffd5d58b")
    add_versions("5.1.0", "9f61b53ce86fd59afb13bc4f48db40e8c8dc156f56879b9e9929014924f95495")
    add_versions("5.0.5", "9693d38b17b000b06cd9fbaff72f4e0873d3cf219a6e99a20bb90cf98a7b562d")
    add_versions("5.0.4", "32b968fb2bd1e33ae854db3bd3fc9ce4374bd9e61ff420f365c52d5f7bbd85dd")
    add_versions("5.0.3", "75a190d1195c641c7d5d2c37ac79d8d1b5f18e43268d023454765a566d6f0d88")
    add_versions("5.0.2", "99adea3e86bd3b83985dce9076adda16968646ebd9d9316c9f57e6854aeeab9c")

    add_patches("*", "patches/5.1.4/arm32.diff", "fc4576406f3603b33fcee733ea5bfd594f1220513f1bb40e23283bf2832d9379")
    add_patches("5.1.0", "patches/5.1.0/fix-freebsd.diff", "98a454d2c71f8f7a63ed5714301ad5f51f92790e3debe5b35a16f14b83c34404")
    add_patches(">=5.0.5", "patches/5.0.5/fix-mingw.diff", "7239f459204975ce2efcf63529dcb09273028c4dc166d7cbacb5f5f0e70f93a9")

    add_deps("capstone", "keystone")

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "psapi", "ntdll", "shell32", "ole32")
        if is_plat("mingw") then
            add_syslinks("uuid")
        end
    elseif is_plat("linux") then
        add_syslinks("dl", "m")
    elseif is_plat("bsd") then
        add_syslinks("dl", "kvm", "procstat", "elf", "m")
    end

    on_check("android", function(package)
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) >= 24, "package(libmem): need ndk api level >= 24 for android")
    end)

    on_load(function(package)
        if package:is_plat("windows") or package:config("shared") then
            package:add("defines", "LM_EXPORT")
        end
    end)

    on_install("windows", "linux|!arm64", "bsd", "mingw", "msys", "android", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <libmem/libmem.h>
            void test() {
                lm_thread_t resultThread;
                lm_bool_t result = LM_GetThread(&resultThread);
            }
        ]]}, {configs = {languages = "c11"}}))

        assert(package:check_cxxsnippets({test = [[
            #include <libmem/libmem.hpp>
            #include <vector>
            #include <optional>
            using namespace libmem;
            void test() {
                std::optional<Thread> currentThread = GetThread();
                std::optional<std::vector<Thread>> threads = EnumThreads();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
