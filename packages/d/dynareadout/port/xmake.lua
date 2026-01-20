set_project("dynareadout")
add_rules("mode.debug", "mode.release")

option("build_cpp", {default = true})
option("build_python", {default = false})
option("profiling", {default = false, defines = "PROFILING"})

target("dynareadout")
    set_kind("$(kind)")
    set_languages("ansi")
    add_options("profiling")
    add_files("src/*.c")
    if not has_config("profiling") then
        remove_files("src/profiling.c")
    end
    add_headerfiles("src/*.h")
    if is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
target_end()

if has_config("build_cpp", "build_python") then
    if is_plat("macosx") then
        add_requires("boost", {configs = {filesystem = true}})
    end
    target("dynareadout_cpp")
        set_kind("$(kind)")
        set_languages("cxx17")
        add_deps("dynareadout")
        add_includedirs("src")
        add_files("src/cpp/*.cpp")
        add_headerfiles("src/cpp/*.hpp")
        if is_kind("shared") then
            add_rules("utils.symbols.export_all", {export_classes = true})
        end
        if is_plat("macosx") then
            add_packages("boost", {public = true})
        end
    target_end()
end

if has_config("build_python") then
    add_requires("pybind11")
    target("pybind11_module")
        set_languages("cxx17")
        add_deps("dynareadout_cpp")
        add_packages("pybind11")
        add_rules("python.module")
        set_basename("dynareadout" .. (is_mode("debug") and "_d" or ""))
        add_options("profiling")
        add_files("src/python/*.cpp")
        add_headerfiles("src/python/*.hpp")
        add_includedirs("src", "src/cpp")
        add_rpathdirs("@executable_path")
end
