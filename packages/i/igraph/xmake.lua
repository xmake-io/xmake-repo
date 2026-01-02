package("igraph")
    set_homepage("https://igraph.org")
    set_description("Library for the analysis of networks")
    set_license("GPL-2.0")

    add_urls("https://github.com/igraph/igraph/releases/download/$(version)/igraph-$(version).tar.gz",
             "https://github.com/igraph/igraph.git")

    add_versions("1.0.1", "969f2d7d22f67e788d8638c9a8c96615f50d7819c08978b3ef4a787bb6daa96c")
    add_versions("1.0.0", "91e23e080634393dec4dfb02c2ae53ac4e3837172bb9047d32e39380b16c0bb0")
    add_versions("0.10.16", "15a1540a8d270232c9aa99adeeffb7787bea96289d6bef6646ec9c91a9a93992")
    add_versions("0.10.15", "03ba01db0544c4e32e51ab66f2356a034394533f61b4e14d769b9bbf5ad5e52c")

    add_configs("glpk", {description = "Compile igraph with GLPK support", default = false, type = "boolean"})
    add_configs("graphml", {description = "Compile igraph with GraphML support", default = false, type = "boolean"})
    add_configs("openmp", {description = "Use OpenMP for parallelization", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("plfit")

    on_check(function (package)
        if package:is_cross() then
            if not package:is_plat("windows", "macosx") then
                raise("package(igraph) unsupported cross-compilation now. To support it, see https://igraph.org/c/html/latest/igraph-Installation.html#igraph-Installation-cross-compiling")
            end
        end
    end)

    on_load(function (package)
        if package:gitref() then
            wprint("If build failed with flex/bison, please see https://github.com/igraph/igraph/issues/2713")
            package:add("deps", "flex", "bison", {kind = "binary"})
        end

        -- TODO: unbundle deps gmp, arpack, blas, lapack
        -- https://igraph.org/c/html/latest/igraph-Installation.html#igraph-Installation-prerequisites
        if package:is_plat("linux", "macosx") then
            package:add("deps", "gmp")
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
        if package:config("graphml") then
            io.replace("etc/cmake/dependencies.cmake", "find_package(LibXml2 ${LIBXML2_VERSION_MIN} QUIET)", "find_package(LibXml2 CONFIG REQUIRED)", {plain = true})
        end
        if package:gitref() then
            io.writefile("IGRAPH_VERSION", package:version_str())
        end

        -- https://igraph.org/c/html/latest/igraph-Installation.html
        local configs = {
            "-DUSE_CCACHE=OFF",
            "-DIGRAPH_WARNINGS_AS_ERRORS=OFF",
            -- "-DIGRAPH_USE_INTERNAL_GMP=OFF",
            -- "-DIGRAPH_USE_INTERNAL_ARPACK=OFF",
            -- "-DIGRAPH_USE_INTERNAL_BLAS=OFF",
            -- "-DIGRAPH_USE_INTERNAL_LAPACK=OFF",
            "-DIGRAPH_USE_INTERNAL_GLPK=OFF",
            "-DIGRAPH_USE_INTERNAL_PLFIT=OFF",
        }
        if package:is_plat("linux", "macosx") then
            table.insert(configs, "-DIGRAPH_USE_INTERNAL_GMP=OFF")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DIGRAPH_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DIGRAPH_GLPK_SUPPORT=" .. (package:config("glpk") and "ON" or "OFF"))
        table.insert(configs, "-DIGRAPH_OPENMP_SUPPORT=" .. (package:config("openmp") and "ON" or "OFF"))
        -- AUTO -> find_package, ON -> find_dependency (unavailable)
        table.insert(configs, "-DIGRAPH_GRAPHML_SUPPORT=" .. (package:config("graphml") and "AUTO" or "OFF"))
        if package:is_cross() then
            -- from https://github.com/microsoft/vcpkg/tree/0857a4b08c14030bbe41e80accb2b1fddb047a74/ports/igraph
            local header
            if package:is_plat("macosx") then
                header = "arith_osx.h"
            elseif package:is_plat("windows") then
                if package:is_arch64() then
                    header = "arith_win64.h"
                else
                    header = "arith_win32.h"
                end
            end

            if header then
                local header_path = path.unix(path.join(os.scriptdir(), header))
                table.insert(configs, "-DF2C_EXTERNAL_ARITH_HEADER=" .. header_path)
            end
        end

        local opt = {}
        if package:config("glpk") then
            opt.packagedeps = "zlib"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("igraph_rng_seed", {includes = "igraph/igraph.h"}))
    end)
