add_rules("mode.debug", "mode.release")
add_requires("eigen", "glfw", "glew", "rply")
option("utils")
    set_default(false)
    set_showmenu(true)
option_end()
target("pmp")
    set_kind("static")
    set_languages("c++11")
    add_files("src/pmp/*.cpp")
    add_files("src/pmp/algorithms/*.cpp")
    add_defines("_USE_MATH_DEFINES", {public = true})
    add_packages("eigen", {public = true})
    add_packages("rply")
    add_includedirs("src", {public = true})
    add_headerfiles("src/(pmp/*.h)")
    add_headerfiles("src/(pmp/algorithms/*.h)")
target_end()
target("pmp_vis")
    set_kind("static")
    set_languages("c++11")
    add_deps("pmp")
    add_packages("glew", "glfw", {public = true})
    add_includedirs("external/imgui", {public = true})
    add_files("external/imgui/*.cpp")
    add_includedirs("external/stb_image", {public = true})
    add_files("external/stb_image/*.cpp")
    add_files("src/pmp/visualization/*.cpp")
    add_headerfiles("src/(pmp/visualization/*.h)")
target_end()
if has_config("utils") then

local apps = {"mview", "curview", "subdiv", "smoothing", "fairing", "parameterization", "decimation", "remeshing", "mpview"}
if not is_plat("windows") then table.insert(apps, "mconvert") end
for _, app in ipairs(apps) do
target(app)
    set_kind("binary")
    set_languages("c++11")
    add_deps("pmp_vis")
    add_files("src/apps/" .. app .. ".cpp")
    if app == "mpview" then add_files("src/apps/MeshProcessingViewer.cpp") end
target_end()
end

end