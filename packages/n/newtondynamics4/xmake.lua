package("newtondynamics4")
    set_homepage("http://newtondynamics.com")
    set_description("Newton Dynamics is an integrated solution for real time simulation of physics environments.")
    set_license("zlib")

    add_urls("https://github.com/MADEAPPS/newton-dynamics/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MADEAPPS/newton-dynamics.git")

    add_versions("v4.02", "13050bc4eac34303ad3ff3bca104cc0ebfacc8551c98d02d4f8505cf9ecd9532")
    add_versions("v4.01", "c92b64f33488c4774debc110418cbc713fd8e07f37b15e4917b92a7a8d5e785a")
    add_patches("v4.01", path.join(os.scriptdir(), "patches", "v4.01", "cmake.patch"), "a189d6282640b6d46c5f9d0926930bbc2d7bb4f242383fae3521b6b211f569e7")

    add_configs("symbols",  {description = "Enable debug symbols in release", default = false, type = "boolean"})

    add_includedirs("include", "include/ndCore", "include/ndCollision", "include/ndNewton")

    add_deps("cmake")

    add_links("ndNewton")

    if is_plat("linux", "android") then
        add_syslinks("dl", "pthread")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "_D_CORE_DLL")
            package:add("defines", "_D_COLLISION_DLL")
            package:add("defines", "_D_NEWTON_DLL")
            package:add("defines", "_D_D_TINY_DLL")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        os.cd("newton-4.00")
        local configs = {
            "-DNEWTON_BUILD_SANDBOX_DEMOS=OFF", 
            "-DNEWTON_BUILD_TEST=OFF", 
            "-DNEWTON_BUILD_CREATE_SUB_PROJECTS=OFF",
            "-DNEWTON_ENABLE_AVX2_SOLVER=OFF"
        }
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DNEWTON_BUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            table.insert(configs, "-DNEWTON_BUILD_SHARED_LIBS=OFF")
        end
        if package:debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
        elseif package:config("symbols") then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=RelWithDebInfo")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                ndWorld world;
                world.Update(0.01f);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "ndNewton/ndNewton.h"}))
    end)
