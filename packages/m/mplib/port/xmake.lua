option("python", {default = false})

add_requires("ompl", "assimp", "orocos-kdl", "urdfdom")
add_requires("pinocchio 2.x", {configs = {urdf = true}})
add_requires("fcl", {configs = {octomap = true}})
if has_config("python") then
    add_requires("pybind11")
end

set_languages("c++17")

target("mp")
    set_kind("$(kind)")
    add_files("src/**.cpp")
    add_includedirs("include", {public = true})
    add_cxflags("/permissive-", "/bigobj", {tools = "cl"})
    add_headerfiles("include/(**.h)")

    add_packages("ompl", "fcl", "pinocchio", "assimp", "orocos-kdl", "urdfdom", {public = true})

target("pymp")
    if has_config("python") then
        add_rules("python.library", {soabi = true})
    else
        set_default(false)
    end
    add_files("pybind/**.cpp")
    add_includedirs("pybind")

    add_deps("mp")
    add_packages("pybind11")
