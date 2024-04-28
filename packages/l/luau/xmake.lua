package("luau")

    set_homepage("https://luau-lang.org/")
    set_description("A fast, small, safe, gradually typed embeddable scripting language derived from Lua.")
    set_license("MIT")

    add_urls("https://github.com/Roblox/luau/archive/$(version).tar.gz",
             "https://github.com/Roblox/luau.git")
    
    add_versions("0.623", "5a72f9e5b996c5ec44ee2c7bd9448d2b2e5061bdf7d057de7490f92fb3003f40")
    add_versions("0.538", "8a1240e02a7daacf1e5cff249040a3298c013157fc496c66adce6dcb21cc30be")

    add_configs("extern_c", { description = "Use extern C for all APIs.", default = false, type = "boolean" })
    add_configs("build_web", { description = "Build web module.", default = false, type = "boolean" })

    add_deps("cmake")

    on_install("linux", "windows", "mingw|x86_64", "macosx", function(package)
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
        for link in string.gmatch(cmake_file, "add_library%(([%a|%.]+)") do
            if string.startswith(link, "Luau.") then
                table.insert(links, link)
            end
        end

        -- we have to link in reverse order
        for i = #links, 1, -1 do
            local link = links[i]
            package:add("links", link)
            link = link:gsub("Luau%.", "")
            link = link:gsub("%..*", "")
            os.trycp(link .. "/include/*", package:installdir("include"))
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
        ]]}))
        assert(package:check_cxxsnippets({ test = [[
            #include <Luau/Common.h>

            void test() {
                Luau::FValue<int> v("test", 42, true);
            }
        ]]}))
    end)
