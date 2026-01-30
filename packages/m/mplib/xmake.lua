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
    add_deps("pinocchio 2.x", {configs = {urdf = true}})
    add_deps("fcl", {configs = {octomap = true}})

    if on_check then
        on_check(function (package)
            if not package:is_plat("windows", "linux", "macosx") then
                raise("deps octomap is only supported on windows, macosx and linux")
            end
        end)
    end

    on_install(function (package)
        if package:has_tool("cxx", "clang", "clang_cl") then
            for _, filepath in ipairs(os.files("src/**.cpp") ) do
                local content = io.readfile(filepath)
                
                local moved_lines = {}
                local found_any = false

                local pattern = "([ \t]*DEFINE_TEMPLATE_[%w_]+%s*%b();[\r\n]*)"
                local clean_content = content:gsub(pattern, function(match)
                    found_any = true
                    table.insert(moved_lines, match:trim())
                    return ""
                end)

                if found_any then
                    local pre_brace, brace, post_brace = clean_content:match("^(.*)(})(.*)$")

                    if pre_brace and brace then
                        local insertion = "\n" .. table.concat(moved_lines, "\n") .. "\n"
                        local new_content = pre_brace .. insertion .. brace .. post_brace
                        
                        io.writefile(filepath, new_content)
                    end
                end
            end
        end

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
