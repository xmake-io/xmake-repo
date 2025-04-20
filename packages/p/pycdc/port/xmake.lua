add_rules("mode.debug", "mode.release")

set_languages("c++11")

target("pycxx")
    set_kind("$(kind)")
    add_files(
        "bytecode.cpp",
        "data.cpp",
        "pyc_*.cpp",
        "bytes/python_*.cpp"
    )
    add_includedirs(os.projectdir())
    add_headerfiles("*.h")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end

target("pycdas")
    set_kind("binary")
    add_files("pycdas.cpp")
    add_deps("pycxx")

target("pycdc")
    set_kind("binary")
    add_files("pycdc.cpp", "ASTree.cpp", "ASTNode.cpp")
    add_deps("pycxx")
