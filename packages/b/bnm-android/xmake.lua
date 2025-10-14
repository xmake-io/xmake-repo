package("bnm-android")
    set_homepage("https://github.com/ByNameModding/BNM-Android")
    set_description("Modding il2cpp games by classes, methods, fields names on Android.")

    add_urls("https://github.com/ByNameModding/BNM-Android.git")
    add_versions("2025.10.14", "502928771983d29e37f28c78f28823dfb775a3aa")

    add_configs("link_log", {description = "Link against liblog.so", default = false, type = "boolean"})
    add_configs("hook_lib", {
        description = "Choose the hooking library used (dobby or shadowhook).",
        default = "shadowhook",
        type = "string",
        values = {"shadowhook", "dobby"},
    })

    on_load(function (package)
        if package:config("hook_lib") == "dobby" then
            package:add("deps", "dobby")
        elseif package:config("hook_lib") == "shadowhook" then
            package:add("deps", "shadowhook")
        end
    end)

    on_install("android", function (package)
        local dummy_impl = [[// Dummy
#include <cassert>

static_assert(false, "No hooking software!");

template<typename PTR_T, typename NEW_T, typename T_OLD>
inline void *BasicHook(PTR_T ptr, NEW_T newMethod, T_OLD &oldBytes) {
    if ((void *) ptr != nullptr) ((void)0);
    return nullptr;
}

template<typename PTR_T, typename NEW_T, typename T_OLD>
inline void *BasicHook(PTR_T ptr, NEW_T newMethod, T_OLD &&oldBytes) {
    if ((void *) ptr != nullptr) ((void)0);
    return nullptr;
}

template<typename PTR_T>
inline void Unhook(PTR_T ptr) {
    if ((void *) ptr != nullptr) ((void)0);
}
]]
    
        if package:config("hook_lib") == "dobby" then
            io.replace("include/BNM/UserSettings/GlobalSettings.hpp", dummy_impl,  [[
#include <dobby.h>

template<typename PTR_T, typename NEW_T, typename T_OLD>
inline void *BasicHook(PTR_T ptr, NEW_T newMethod, T_OLD &oldBytes) {
    if ((void *) ptr != nullptr) DobbyHook((void *)ptr, (void *) newMethod, (void **) &oldBytes);
    return (void *) ptr;
}

template<typename PTR_T, typename NEW_T, typename T_OLD>
inline void *BasicHook(PTR_T ptr, NEW_T newMethod, T_OLD &&oldBytes) {
    if ((void *) ptr != nullptr) DobbyHook((void *)ptr, (void *) newMethod, (void **) &oldBytes);
    return (void *) ptr;
}

template<typename PTR_T>
inline void Unhook(PTR_T ptr) {
    if ((void *) ptr != nullptr) DobbyDestroy((void *)ptr);
}
]], {plain = true})
        elseif package:config("hook_lib") == "shadowhook" then
            io.replace("include/BNM/UserSettings/GlobalSettings.hpp", dummy_impl, [[
#include "shadowhook.h"
template<typename PTR_T, typename NEW_T, typename T_OLD>
inline void *BasicHook(PTR_T ptr, NEW_T newMethod, T_OLD &oldBytes) {
    if ((void *) ptr != nullptr) return shadowhook_hook_func_addr((void *)ptr, (void *) newMethod, (void **) &oldBytes);
    return nullptr;
}

template<typename PTR_T, typename NEW_T, typename T_OLD>
inline void *BasicHook(PTR_T ptr, NEW_T newMethod, T_OLD &&oldBytes) {
    if ((void *) ptr != nullptr) return shadowhook_hook_func_addr((void *)ptr, (void *) newMethod, (void **) &oldBytes);
    return nullptr;
}

template<typename PTR_T>
inline void Unhook(PTR_T ptr) {
    if ((void *) ptr != nullptr) shadowhook_unhook((void *)ptr);
}
            ]], {plain = true})
        else
            raise("Unknown hooking library: " .. package:config("hook_lib"))
        end

        io.writefile("xmake.lua", [[
set_project("BNM")
set_version("1.0.0")

set_languages("c++20")

add_rules("mode.debug", "mode.release")

if is_config("hook_lib", "dobby") then
    add_requires("dobby")
elseif is_config("hook_lib", "shadowhook") then
    add_requires("shadowhook")
end

option("link_log")
option("hook_lib")

target("BNM")
    set_kind("static")
    if is_config("hook_lib", "dobby") then
        add_packages("dobby", {public = true})
    elseif is_config("hook_lib", "shadowhook") then
        add_packages("shadowhook", {public = true})
    end

    add_files("src/*.cpp")
    
    add_headerfiles("include/(**.h)", "include/(**.hpp)")
    add_headerfiles("external/include/(**.h)", "external/include/(**.hpp)")
    add_includedirs("include", "external/include", "external", "external/utf8", "src/private")
    
    if has_config("link_log") then
        add_syslinks("log")
    end
    
    set_configvar("BNM_INCLUDE_DIRECTORIES", "include;external/include")
        ]])
        import("package.tools.xmake").install(package, {
            link_log = package:config("link_log"),
            hook_lib = package:config("hook_lib"),
        })
    end)

    on_test(function (package)
        package:check_cxxsnippets({test = [[
            void test() {
                BNM::Loading::TryLoadByUsersFinder();
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"BNM/Loading.hpp"}})
    end)
