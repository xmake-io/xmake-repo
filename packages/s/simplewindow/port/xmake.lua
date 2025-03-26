add_rules("mode.debug", "mode.release")
set_languages("c++14")

target("simplewindow")
    set_kind("$(kind)")
    add_cxxflags("/utf-8")
    add_includedirs("inc")
    add_headerfiles("inc/(*.h)")
    add_files("src/*.cpp")
    after_install(function (target)
        os.mv("inc", "sw")
        os.cp("sw", path.join(target:installdir("include"), "sw"))
    end)
