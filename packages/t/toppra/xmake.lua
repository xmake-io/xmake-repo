package("toppra")
    set_homepage("https://hungpham2511.github.io/toppra/index.html")
    set_description("robotic motion planning library")
    set_license("MIT")

    add_urls("https://github.com/hungpham2511/toppra/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hungpham2511/toppra.git")

    add_versions("v0.6.4", "31213336fc36a69e8003808e7317773ba7c78e503c8cbd6d01fe2d50660e3294")

    add_configs("pinocchio", {description = "Compile with Pinocchio library", default = false, type = "boolean"})
    add_configs("qpoases", {description = "Compile the wrapper for qpOASES", default = false, type = "boolean"})
    add_configs("glpk", {description = "Compile the wrapper for GLPK (GPL license)", default = false, type = "boolean"})
    add_configs("python", {description = "Build Python bindings.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("eigen")

    on_load(function (package)
        if package:config("pinocchio") then
            package:add("deps", "pinocchio")
        end
        if package:config("qpoases") then
            package:add("deps", "qpoases") -- TODO
        end
        if package:config("glpk") then
            package:add("deps", "glpk")
        end
        if package:config("python") then
            package:add("deps", "python 3.x", "pybind11")
        end
        if not package:config("shared") then
            package:add("defines", "TOPPRA_STATIC_DEFINE")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DEIGEN3_VERSION_STRING=" .. package:dep("eigen"):version_str()}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_WITH_PINOCCHIO=" .. (package:config("pinocchio") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_WITH_qpOASES=" .. (package:config("qpoases") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_WITH_GLPK=" .. (package:config("glpk") and "ON" or "OFF"))
        table.insert(configs, "-DPYTHON_BINDINGS=" .. (package:config("python") and "ON" or "OFF"))

        os.cd("cpp")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto solver = toppra::Solver::createDefault();
            }
        ]]}, {configs = {languages = "c++14"}, includes = "toppra/solver.hpp"}))
    end)
