package("igraph")
    set_homepage("https://igraph.org")
    set_description("Library for the analysis of networks")
    set_license("GPL-2.0")

    add_urls("https://github.com/igraph/igraph/archive/refs/tags/$(version).tar.gz",
             "https://github.com/igraph/igraph.git")

    add_versions("0.10.15", "65a0ba01888a4c5b3e0437e4d9a5bd9e8e93a1897cf5fc4e560e3586f4a43deb")

    add_configs("glpk", {description = "Compile igraph with GLPK support", default = false, type = "boolean"})
    add_configs("graphml", {description = "Compile igraph with GraphML support", default = false, type = "boolean"})
    add_configs("openmp", {description = "Use OpenMP for parallelization", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("debug", {description = "Enable debug symbols.", default = false, readonly = true})
    elseif is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "flex", "bison", {kind = "binary"})
    add_deps("plfit")

    on_check(function (package)
        if package:is_cross() then
            raise("package(igraph) unsupported cross-compilation")
        end
        if is_subhost("msys") and xmake:version():lt("2.9.7") then
            raise("package(igraph) requires xmake >= 2.9.7 on msys")
        end
    end)

    on_load(function (package)
        if package:is_plat("linux", "macosx") then
            package:add("deps", "gmp")
            -- if package:is_plat("linux") then
            --     package:add("deps", "lapack")
            -- end
        end

        if package:config("glpk") then
            package:add("deps", "glpk")
        end
        if package:config("graphml") then
            package:add("deps", "libxml2")
        end
        if package:config("openmp") then
            package:add("deps", "openmp")
        end

        if not package:config("shared") then
            package:add("defines", "IGRAPH_STATIC")
        end
    end)

    on_install("!cross and !bsd", function (package)
        -- Disable test/doc/cpack
        io.replace("CMakeLists.txt", "CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME", "0", {plain = true})
        io.writefile("IGRAPH_VERSION", package:version_str())

        -- https://igraph.org/c/html/latest/igraph-Installation.html
        local configs = {
            "-DIGRAPH_WARNINGS_AS_ERRORS=OFF"
            -- "-DIGRAPH_USE_INTERNAL_GMP=OFF",
            -- "-DIGRAPH_USE_INTERNAL_ARPACK=OFF",
            -- "-DIGRAPH_USE_INTERNAL_BLAS=OFF",
            -- "-DIGRAPH_USE_INTERNAL_LAPACK=OFF",
            "-DIGRAPH_USE_INTERNAL_GLPK=OFF",
            "-DIGRAPH_USE_INTERNAL_PLFIT=OFF",
        }
        if package:is_plat("linux", "macosx") then
            table.insert(configs, "-DIGRAPH_USE_INTERNAL_GMP=OFF")
            -- if package:is_plat("linux") then
            --     table.insert(configs, "-DIGRAPH_USE_INTERNAL_LAPACK=OFF")
            -- end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DIGRAPH_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DIGRAPH_GLPK_SUPPORT=" .. (package:config("glpk") and "ON" or "OFF"))
        table.insert(configs, "-DIGRAPH_GRAPHML_SUPPORT=" .. (package:config("graphml") and "ON" or "OFF"))
        table.insert(configs, "-DIGRAPH_OPENMP_SUPPORT=" .. (package:config("openmp") and "ON" or "OFF"))

        local opt = {}
        if package:config("glpk") then
            opt.packagedeps = "zlib"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("igraph_rng_seed", {includes = "igraph/igraph.h"}))
    end)
