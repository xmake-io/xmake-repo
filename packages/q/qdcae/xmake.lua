package("qdcae")

    set_homepage("https://github.com/qd-cae/qd-cae-python")
    set_description("qd python (and C++) library for CAE (currently mostly LS-Dyna) ")

    set_urls("https://github.com/qd-cae/qd-cae-python/archive/$(version).zip",
             "https://github.com/qd-cae/qd-cae-python.git")
    add_versions("0.8.9", "d5e838a7685d3407919c3e6ad33a17a8bfe376df26dbcc74a5368d8e8fd64c4c")
    add_patches("0.8.9", path.join(os.scriptdir(), "patches", "fix.patch"), "b865ac7c0db7bd792aa536a9ca8b7d504b04cce7e7aea2073dbc00e276f5b8fc")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install("linux", "windows", "mingw", "bsd", function (package)
        io.writefile("xmake.lua", [[
        add_rules("mode.debug", "mode.release")
        target("qdcae_dyna")
            set_kind("$(kind)")
            add_files("qd/cae/dyna_cpp/**.cpp", "qd/cae/dyna_cpp/**.c")
            del_files("qd/cae/dyna_cpp/dyna/d3plot/ArrayD3plot.cpp",
                      "qd/cae/dyna_cpp/dyna/d3plot/D3plotHeader.cpp",
                      "qd/cae/dyna_cpp/dyna/d3plot/FemzipBuffer.cpp",
                      "qd/cae/dyna_cpp/utility/HDF5_Utility.cpp",
                      "qd/cae/dyna_cpp/python_api/*.cpp",
                      "**test.cpp")
            add_includedirs("qd/cae")

            set_languages("c11", "cxx11")
        ]])

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
        os.cp("qd/cae/dyna_cpp/**.h",   path.join(package:installdir(), "include"), {rootdir = "qd/cae"})
        os.cp("qd/cae/dyna_cpp/**.hpp", path.join(package:installdir(), "include"), {rootdir = "qd/cae"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                qd::D3plot file("d3plot", std::string());
            }
        ]]}, {includes = "dyna_cpp/dyna/d3plot/D3plot.hpp", languages="cxx11"}))
    end)

