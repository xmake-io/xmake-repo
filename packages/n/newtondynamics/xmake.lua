package("newtondynamics")
    set_homepage("http://newtondynamics.com")
    set_description("Newton Dynamics is an integrated solution for real time simulation of physics environments.")
    set_license("zlib")

    set_urls("https://github.com/MADEAPPS/newton-dynamics/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MADEAPPS/newton-dynamics.git")

    add_versions("v3.14c", "042342e021a429f4b689bf7aa2ed5b6d4b9b7abcde0eea57daa5873736073d22")

    add_deps("cmake")

    add_includedirs("include", "include/dgCore")

    on_load(function (package)
        if package:is_plat("windows") then
            if not package:config("shared") then
                package:add("defines", "_NEWTON_STATIC_LIB")
            end

            if package:is_arch("x86") then
                package:add("defines", "_WIN_64_VER")
            else
                package:add("defines", "_WIN_32_VER")
            end
        end

        if package:is_plat("linux", "macosx", "iphoneos", "android") then
            if package:is_arch("x86") then
                package:add("defines", "_POSIX_VER_64")
            else
                package:add("defines", "_POSIX_VER")
            end
        end
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "mingw", "android", function (package)
        -- prevent cmakelists.txt from overwriting CMAKE_INSTALL_PREFIX
        io.replace("CMakeLists.txt", [[set(CMAKE_INSTALL_PREFIX "win64sdk" CACHE PATH "..." FORCE)]], "", {plain = true})
        io.replace("CMakeLists.txt", [[set(CMAKE_INSTALL_PREFIX "win32sdk" CACHE PATH "..." FORCE)]], "", {plain = true})

        local configs = {"-DNEWTON_BUILD_SANDBOX_DEMOS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DNEWTON_BUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DNEWTON_BUILD_SHARED_LIBS=OFF")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DNEWTON_STATIC_RUNTIME_LIBRARIES=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
   end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                NewtonWorld* world = NewtonCreate();
                NewtonDestroy(world);
            }
        ]]}, {includes = "newton/Newton.h"}))
    end)
