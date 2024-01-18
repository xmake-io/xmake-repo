package("pystring")

    set_homepage("https://github.com/imageworks/pystring")
    set_description("Pystring is a collection of C++ functions which match the interface and behavior of python's string class methods using std::string.")

    add_urls("https://github.com/imageworks/pystring.git")
    add_versions("2020.02.04", "281419de2f91f9e0f2df6acddfea3b06a43436be")
    add_versions("2023.07.23", "76a2024e132bcc83bec1ecfebeacd5d20d490bfe")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("pystring")
                set_kind("static")
                add_files("pystring.cpp")
                add_headerfiles("pystring.h", {prefixdir = "pystring"})
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                bool res = pystring::endswith("abcdef", "cdef");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "pystring/pystring.h"}))
    end)
