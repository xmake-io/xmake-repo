package("bullet3")
    set_homepage("http://bulletphysics.org")
    set_description("Bullet Physics SDK.")
    set_license("zlib")

    set_urls("https://github.com/bulletphysics/bullet3/archive/$(version).zip",
             "https://github.com/bulletphysics/bullet3.git")
    add_versions("2.88", "f361d10961021a186b80821cfc1cfafc8dac48ce35f7d5e8de0943af4b3ddce4")
    add_versions("3.05", "e7ef322d8038e397cd6d79145a856cf5b4d558ce091d49b5239d625a46fef0d7")
    add_versions("3.09", "8443894e47167cf7f7b4433a365b428ebeb83ba64d64f2a741ec4d2da4992c3d")
    add_versions("3.24", "1179bcc5cdaf7f73f92f5e8495eaadd6a7216e78cad22f1027e9ce49b7a0bfbe")
    add_versions("3.25", "b9bc8d1443637a9084e2b585ed582abf2da3ddad7d768acccfe4ee17aca56bf7")

    add_configs("double_precision", {description = "Enable double precision floats", default = false, type = "boolean"})
    add_configs("extras",           {description = "Build the extras", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    
    add_deps("cmake")
    add_links("Bullet2FileLoader", "Bullet3Collision", "Bullet3Common", "Bullet3Dynamics", "Bullet3Geometry", "Bullet3OpenCL_clew", "BulletDynamics", "BulletCollision", "BulletInverseDynamics", "BulletSoftBody", "LinearMath")
    add_includedirs("include", "include/bullet")

    on_install(function (package)
        local configs = {"-DBUILD_CPU_DEMOS=OFF", "-DBUILD_OPENGL3_DEMOS=OFF", "-DBUILD_BULLET2_DEMOS=OFF", "-DBUILD_UNIT_TESTS=OFF", "-DINSTALL_LIBS=ON", "-DCMAKE_DEBUG_POSTFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_DOUBLE_PRECISION=" .. (package:config("double_precision") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_EXTRAS=" .. (package:config("extras") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DUSE_MSVC_RUNTIME_LIBRARY_DLL=" .. (package:config("vs_runtime"):startswith("MD") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                btDefaultCollisionConfiguration collisionConfiguration;
                btCollisionDispatcher dispatcher(&collisionConfiguration);
                btDbvtBroadphase broadphase;
                btSequentialImpulseConstraintSolver constraintSolver;
                btDiscreteDynamicsWorld dynamicWorld(&dispatcher, &broadphase, &constraintSolver, &collisionConfiguration);
                dynamicWorld.setGravity(btVector3(0, -10, 0));

                broadphase.optimize();
            }
        ]]}, {includes = "bullet/btBulletDynamicsCommon.h"}))
    end)
