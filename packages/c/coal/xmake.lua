package("coal")
    set_homepage("https://github.com/coal-library/coal")
    set_description("An extension of the Flexible Collision Library")
    set_license("BSD")

    add_urls("https://github.com/coal-library/coal/archive/refs/tags/$(version).tar.gz",
             "https://github.com/coal-library/coal.git", {submodules = false})

    add_versions("v3.0.2", "86d47608d748762b343990095b6a7c79ee20182e3193da92c17545c5aae780b7")

    add_configs("logging", {description = "Activate logging for warnings or error messages. Turned on by default in Debug.", default = false, type = "boolean"})
    add_configs("float", {description = "Use float precision (32-bit) instead of the default double precision (64-bit)", default = false, type = "boolean"})
    add_configs("qhull", {description = "use qhull library to compute convex hulls.", default = false, type = "boolean"})

    add_deps("cmake", "jrl-cmakemodules")
    add_deps("eigen", "assimp")

    on_load(function (package)
        local boost_configs = {
            math          = true,
            thread        = true,
            regex         = true,
            filesystem    = true,
            serialization = true,
        }
        if package:config("logging") then
            boost_configs.log = true
        end
        package:add("deps", "boost", {configs = boost_configs})

        if package:config("qhull") then
            package:add("deps", "qhull")
        end

        if package:config("float") then
            package:add("defines", "COAL_USE_FLOAT_PRECISION")
        end
        if not package:config("shared") then
            package:add("defines", "COAL_STATIC")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "SET_BOOST_DEFAULT_OPTIONS()", "", {plain = true})
        io.replace("CMakeLists.txt", "EXPORT_BOOST_DEFAULT_OPTIONS()", "", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_PYTHON_INTERFACE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCOAL_ENABLE_LOGGING=" .. (package:config("logging") and "ON" or "OFF"))
        table.insert(configs, "-DCOAL_USE_FLOAT_PRECISION=" .. (package:config("float") and "ON" or "OFF"))
        table.insert(configs, "-DCOAL_HAS_QHULL=" .. (package:config("qhull") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <coal/math/transform.h>
            #include <coal/mesh_loader/loader.h>
            #include <coal/BVH/BVH_model.h>
            #include <coal/collision.h>

            std::shared_ptr<coal::ConvexBase> loadConvexMesh(const std::string& file_name) {
                coal::NODE_TYPE bv_type = coal::BV_AABB;
                coal::MeshLoader loader(bv_type);
                coal::BVHModelPtr_t bvh = loader.load(file_name);
                bvh->buildConvexHull(true, "Qt");
                return bvh->convex;
            }
            void test() {
                std::shared_ptr<coal::Ellipsoid> shape1 = std::make_shared<coal::Ellipsoid>(0.7, 1.0, 0.8);
                std::shared_ptr<coal::ConvexBase> shape2 = loadConvexMesh("../path/to/mesh/file.obj");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
