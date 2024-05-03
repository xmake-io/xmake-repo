package("jsbsim")
    set_homepage("https://github.com/JSBSim-Team/jsbsim")
    set_description("An open source flight dynamics & control software library")
    set_license("LGPL-2.1")

    add_urls("https://github.com/JSBSim-Team/jsbsim/archive/refs/tags/$(version).tar.gz",
             "https://github.com/JSBSim-Team/jsbsim.git")

    add_versions("v1.2.0", "1ac7d594ba4de3582ec1bff972a298af8d65651dd5fc547240ea407b25396d80")

    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32")
    end

    add_includedirs("include", "include/JSBSim")
    add_links("Aeromatic++", "JSBSim")

    add_deps("cmake")
    add_deps("expat")

    on_install("windows", "linux", "macosx", "mingw", function (package)
        if package:is_plat("windows", "mingw") and (not package:config("shared")) then
            package:add("defines", "JSBSIM_STATIC_LINK")
        end

        local configs = {
            "-DSYSTEM_EXPAT=OFF",
            "-DBUILD_DOCS=OFF",
            "-DENABLE_TESTING=OFF",
            "-DBUILD_PYTHON_MODULE=OFF",
            "-DCPACK_RPM_COMPONENT_INSTALL=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "expat"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                JSBSim::FGFDMExec FDMExec;
                FDMExec.RunIC();
            }
        ]]}, {configs = {languages = "c++14"}, includes = "JSBSim/FGFDMExec.h"}))
    end)
