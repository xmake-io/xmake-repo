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
    add_configs("unity_version", {
        description = "Unity version (e.g., 5.6.4, 2017.1.0, 2022.2.1)",
        default = "2022.2.0",
        type = "string",
    })

    on_load(function (package)
        package:add("deps", package:config("hook_lib"))
    end)

    local parse_unity_version = function (version)
        local major, minor, patch = version:match("^(%d+)%.(%d+)%.(%d+)")
        if not major then
            major, minor = version:match("^(%d+)%.(%d+)%.%w+")
            if not major then
                return 222, 32
            end
            patch = nil
        end
        
        major = tonumber(major)
        minor = tonumber(minor)
        patch = patch and tonumber(patch) or nil
        
        local unity_ver
        local unity_patch_ver
        
        if major == 5 then
            if minor == 6 then
                unity_ver = 56
            end
        elseif major == 2017 then
            if minor == 1 then
                unity_ver = 171
            elseif minor >= 2 and minor <= 4 then
                unity_ver = 172
            end
        elseif major == 2018 then
            if minor == 1 then
                unity_ver = 181
            elseif minor == 2 then
                unity_ver = 182
            elseif minor >= 3 then
                unity_ver = 183
            end
        elseif major == 2019 then
            if minor <= 2 then
                unity_ver = 191
            elseif minor == 3 then
                unity_ver = 193
            elseif minor == 4 then
                unity_ver = 194
            end
        elseif major == 2020 then
            if minor == 1 then
                unity_ver = 201
            elseif minor == 2 then
                unity_ver = 202
            elseif minor == 3 then
                if patch and patch >= 20 then
                    unity_ver = 203
                else
                    unity_ver = 202
                end
            end
        elseif major == 2021 then
            if minor == 1 then
                unity_ver = 211
                -- Need to set UNITY_PATCH_VER to 24 if x (2021.1.x) >= 24
                if patch and patch >= 24 then
                    unity_patch_ver = patch
                end
            elseif minor == 2 then
                unity_ver = 212
            elseif minor == 3 then
                unity_ver = 213
            end
        elseif major == 2022 then
            if minor == 1 then
                unity_ver = 221
            elseif minor >= 2 then
                unity_ver = 222
                unity_patch_ver = patch or 32
            end
        elseif major == 2023 then
            if minor == 1 then
                unity_ver = 231
            elseif minor >= 2 then
                unity_ver = 232
            end
        end
        
        -- Fallback to default if no match found
        if not unity_ver then
            unity_ver = 222
            unity_patch_ver = 32
        end
        
        return unity_ver, unity_patch_ver
    end

    on_install("android", function (package)
        local unity_version = package:config("unity_version")
        local unity_ver, unity_patch_ver = parse_unity_version(unity_version)
        
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

        io.replace("include/BNM/UserSettings/GlobalSettings.hpp", "#define UNITY_VER 222 // 2022.2.x", "#define UNITY_VER " .. unity_ver .. " // " .. unity_version, {plain = true})
        if unity_patch_ver then
            io.replace("include/BNM/UserSettings/GlobalSettings.hpp", "#define UNITY_PATCH_VER 32", "#define UNITY_PATCH_VER " .. unity_patch_ver, {plain = true})
        end
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

        io.replace("include/BNM/UnityStructures/Matrix4x4.hpp", [[#include "Matrix3x3.hpp"]], [[#include "Matrix3x3.hpp"
#include <cmath>]], {plain = true})

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {
            link_log = package:config("link_log"),
            hook_lib = package:config("hook_lib"),
            unity_version = package:config("unity_version"),
            version = package:version_str()
        })
    end)

    on_test(function (package)
        package:check_cxxsnippets({test = [[
            void test() {
                BNM::Loading::TryLoadByUsersFinder();
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"BNM/Loading.hpp"}})
    end)
