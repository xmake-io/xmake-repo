package("luau")

    set_homepage("https://luau-lang.org/")
    set_description("A fast, small, safe, gradually typed embeddable scripting language derived from Lua.")
    set_license("MIT")

    add_urls("https://github.com/Roblox/luau/archive/$(version).tar.gz",
             "https://github.com/Roblox/luau.git")
    
    add_versions("0.624", "6d5ce40a7dc0e17da51cc143d2ee1ab32727583c315938f5a69d13ef93ae574d")
    add_versions("0.623", "5a72f9e5b996c5ec44ee2c7bd9448d2b2e5061bdf7d057de7490f92fb3003f40")
    add_versions("0.538", "8a1240e02a7daacf1e5cff249040a3298c013157fc496c66adce6dcb21cc30be")

    add_configs("extern_c", { description = "Use extern C for all APIs.", default = false, type = "boolean" })
    add_configs("build_web", { description = "Build web module.", default = false, type = "boolean" })

    add_deps("cmake")

    on_install("!bsd and !wasm", function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "RelWithDebInfo"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_BUILD_TESTS=OFF")
        table.insert(configs, "-DLUAU_BUILD_WEB=" .. (package:config("build_web") and "ON" or "OFF"))
        table.insert(configs, "-DLUAU_EXTERN_C=" .. (package:config("extern_c") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, { buildir = "build" })

        io.replace("CMakeLists.txt", ".lib", "", {plain = true})
        io.replace("Sources.cmake", ".lib", "", {plain = true})

        local cmake_file = io.readfile("CMakeLists.txt")

        local links = {}
        for library_name, library_type in string.gmatch(cmake_file, "add_library%(([%a|%.]+) ([STATIC|INTERFACE]+)") do
            if string.startswith(library_name, "Luau.") then
                if library_type == "STATIC" then
                    table.insert(links, library_name)
                end
                local include_dir = library_name:gsub("Luau%.", "")
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
