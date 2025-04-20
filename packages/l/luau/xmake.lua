package("luau")
    set_homepage("https://www.luau.org/")
    set_description("A fast, small, safe, gradually typed embeddable scripting language derived from Lua.")
    set_license("MIT")

    add_urls("https://github.com/luau-lang/luau/archive/refs/tags/$(version).tar.gz",
             "https://github.com/luau-lang/luau.git")
    
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
        io.replace("CMakeLists.txt", [[cmake_policy(SET CMP0054 NEW)]], [[
            cmake_policy(SET CMP0054 NEW)
            cmake_policy(SET CMP0057 NEW)
        ]], {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "RelWithDebInfo"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_BUILD_TESTS=OFF")
        table.insert(configs, "-DLUAU_BUILD_WEB=" .. ((package:is_plat("wasm") or package:config("build_web")) and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_EXTERN_C=" .. (package:config("extern_c") and "ON" or "OFF"))

        if package:is_plat("bsd") then
            io.replace("CMakeLists.txt", [[if(CMAKE_SYSTEM_NAME MATCHES "Linux|Darwin|iOS")]], [[if(TRUE)]], {plain = true})
        end

        if package:is_plat("wasm") then
            import("package.tools.cmake").build(package, configs, { target = "Luau.Web", buildir = "build" })
        else
            import("package.tools.cmake").install(package, configs, { buildir = "build" })
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
        assert(package:check_cxxsnippets({ test = [[
            #include <lua.h>
            #include <luacode.h>
            #include <lualib.h>

            void test() {
                auto L = luaL_newstate();
                luaL_openlibs(L);
                lua_close(L);
            }
        ]]}, {configs = {languages = "cxx11"}}))
        assert(package:check_cxxsnippets({ test = [[
            #include <Luau/Common.h>

            void test() {
                Luau::FValue<int> v("test", 42, true);
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
