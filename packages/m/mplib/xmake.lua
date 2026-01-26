package("mplib")
    set_homepage("https://motion-planning-lib.readthedocs.io/")
    set_description("a Lightweight Motion Planning Package")
    set_license("MIT")

    add_urls("https://github.com/haosulab/MPlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/haosulab/MPlib.git", {submodules = false})

    add_versions("v0.2.1", "ea5b549965994ab7794c73f9c95f49590e473e76513f48e6feb4b37c53e5c4da")

    add_configs("python", {description = "Build Python bindings.", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("ompl", "assimp", "orocos-kdl", "urdfdom")
    add_deps("pinocchio v2.7.1", {configs = {urdf = true}})
    add_deps("fcl", {configs = {octomap = true}})

    if on_check then
        on_check(function (package)
            if not package:is_plat("windows", "linux", "macosx") then
                raise("deps octomap is only supported on windows, macosx and linux")
            end
        end)
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {python = package:config("python")})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mplib/core/articulated_model.h>

            using ArticulatedModel = mplib::ArticulatedModelTpl<double>;

            void test() {
                std::string urdf_filename = "../data/panda/panda.urdf";
                std::string srdf_filename = "../data/panda/panda.srdf";
                Eigen::Vector3d gravity = Eigen::Vector3d(0, 0, -9.81);
                ArticulatedModel articulated_model(urdf_filename, srdf_filename, {}, gravity, {}, {},
                                     false, false);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
