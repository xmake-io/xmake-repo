package("luau")
    set_homepage("https://www.luau.org/")
    set_description("A fast, small, safe, gradually typed embeddable scripting language derived from Lua.")
    set_license("MIT")

    add_urls("https://github.com/luau-lang/luau/archive/refs/tags/$(version).tar.gz",
             "https://github.com/luau-lang/luau.git")
    
    add_versions("696", "95e5727b50547fd6021ef98234bd8b04410b7198d78d05e0faddee9c52b3602f")
    add_versions("0.695", "15280abccdd81171236ee9f139dfd2189d2f5db10f6e50b9bf91148dae94591b")
    add_versions("0.693", "8843dc7d0a961b289c7e71121ca12db7f2ee41b17d428c59f088789fda9632bf")
    add_versions("0.691", "ac4d630d475b352f96ddc511773640a69f146e30f465922e8ce406bd9294df4c")
    add_versions("0.689", "d03c79ee496b732c72f405283ffec07185050ed993347e45a0c4a1518c8cb886")
    add_versions("0.686", "34dd6a83e71a02f684707b7041674779c03961858a8ecefdd74cad36afc31177")
    add_versions("0.683", "a2c7aaf906d625e43ca468792acf8e47a9cbd1d4352623b5e62d2a4011faa15c")
    add_versions("0.643", "069702be7646917728ffcddcc72dae0c4191b95dfe455c8611cc5ad943878d3d")
    add_versions("0.642", "cc7954979d2b1f6a138a9b0cb0f2d27e3c11d109594379551bc290c0461965ba")
    add_versions("0.640", "63ada3e4c8c17e5aff8964b16951bfd1b567329dd81c11ae1144b6e95f354762")
    add_versions("0.638", "87ea29188f0d788e3b8649a063cda6b1e1804a648f425f4d0e65ec8449f2d171")
    add_versions("0.624", "6d5ce40a7dc0e17da51cc143d2ee1ab32727583c315938f5a69d13ef93ae574d")
    add_versions("0.623", "5a72f9e5b996c5ec44ee2c7bd9448d2b2e5061bdf7d057de7490f92fb3003f40")
    add_versions("0.538", "8a1240e02a7daacf1e5cff249040a3298c013157fc496c66adce6dcb21cc30be")

    add_configs("extern_c", { description = "Use extern C for all APIs.", default = false, type = "boolean" })
    add_configs("build_web", { description = "Build web module.", default = false, type = "boolean" })

    add_deps("cmake")

    on_install(function(package)
        io.replace("extern/isocline/src/completers.c", "__finddata64_t", "_finddatai64_t", {plain = true})

        local configs = {"-DLUAU_BUILD_TESTS=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "RelWithDebInfo"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_BUILD_WEB=" .. ((package:is_plat("wasm") or package:config("build_web")) and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_EXTERN_C=" .. (package:config("extern_c") and "ON" or "OFF"))

        if package:is_plat("bsd") then
            io.replace("CMakeLists.txt", [[if(CMAKE_SYSTEM_NAME MATCHES "Linux|Darwin|iOS")]], [[if(TRUE)]], {plain = true})
        end

        if package:is_plat("wasm") then
            import("package.tools.cmake").build(package, configs, { target = "Luau.Web", builddir = "build" })
        else
            import("package.tools.cmake").build(package, configs, { builddir = "build" })
        end

        local cmake_file = io.readfile("CMakeLists.txt")

        local links = {}
        for library_name, library_type in cmake_file:gmatch("add_library%(([%a|%.]+) (%w+)") do
            library_type = library_type:lower()
            if library_name:startswith("Luau.") and (library_type == "static" or library_type == "interface") then
                if library_name:endswith(".lib") then
                    library_name = library_name:sub(1, -5)
                end
                if library_type == "static" then
                    table.insert(links, library_name)
                end
                local include_dir = library_name:sub(6)
                include_dir = include_dir:gsub("%..*", "")
                os.trycp(include_dir .. "/include/*", package:installdir("include"))
            end
        end

        -- we have to link in reverse order
        for i = #links, 1, -1 do
            local link = links[i]
            package:add("links", link)
        end

        os.trycp("build/**.a", package:installdir("lib"))
        os.trycp("build/**.so", package:installdir("lib"))
        os.trycp("build/**.dylib", package:installdir("lib"))
        os.trycp("build/**.lib", package:installdir("lib"))
        os.trycp("build/**.dll", package:installdir("bin"))
        os.trycp("build/luau*", package:installdir("bin"))

        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        if package:config("extern_c") then
            assert(package:check_cxxsnippets({ test = [[
                extern "C" {
                    #include <lua.h>
                    #include <luacode.h>
                    #include <lualib.h>
                }

                void test() {
                    lua_State* L = luaL_newstate();
                    luaL_openlibs(L);
                    lua_close(L);
                }
            ]]}, {configs = {languages = "cxx11"}}))
        else
            assert(package:check_cxxsnippets({ test = [[
                #include <lua.h>
                #include <luacode.h>
                #include <lualib.h>

                void test() {
                    lua_State* L = luaL_newstate();
                    luaL_openlibs(L);
                    lua_close(L);
                }
            ]]}, {configs = {languages = "cxx11"}}))
        end
        assert(package:check_cxxsnippets({ test = [[
            #include <Luau/Common.h>

            void test() {
                Luau::FValue<int> v("test", 42, true);
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
