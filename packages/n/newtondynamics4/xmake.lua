package("newtondynamics4")
    set_homepage("http://newtondynamics.com")
    set_description("Newton Dynamics is an integrated solution for real time simulation of physics environments.")
    set_license("zlib")

    add_urls("https://github.com/MADEAPPS/newton-dynamics/archive/refs/tags/$(version).tar.gz",
             "https://github.com/MADEAPPS/newton-dynamics.git")

    add_versions("v4.01", "c92b64f33488c4774debc110418cbc713fd8e07f37b15e4917b92a7a8d5e785a")
    add_patches("v4.01", path.join(os.scriptdir(), "patches", "v4.01", "cmake.patch"), "005a86d0a97cbc35bb3e4905afe4e6fdc7d8024484d50a8b41dbade601f98149")

    add_includedirs("include", "include/ndCore", "include/ndCollision", "include/ndNewton")

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
        local configs = {"-DNEWTON_BUILD_SANDBOX_DEMOS=OFF", "-DNEWTON_BUILD_TEST=OFF", "-DNEWTON_BUILD_CREATE_SUB_PROJECTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
            table.insert(configs, "-DNEWTON_BUILD_SHARED_LIBS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                ndWorld world;
                world.Update(0.01f);
            }
        ]]}, {includes = "ndNewton/ndNewton.h"}))
    end)
