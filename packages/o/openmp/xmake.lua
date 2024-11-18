package("openmp")
    set_kind("library", {headeronly = true})
    set_homepage("https://openmp.org/")
    set_description("The OpenMP API specification for parallel programming")

    add_configs("runtime",      {description = "Set OpenMP runtime for gcc/clang like compilers.", default = "default", type = "string", values = {"default", "custom"}})
    add_configs("feature",      {description = "Set OpenMP feature for msvc.", default = "default", type = "string", values = {"default", "experimental", "llvm"}})

    on_load(function (package)
        if package.has_tool then
            for _, toolkind in ipairs({"cc", "cxx", "fc"}) do
                if package:config("runtime") == "default" then
                    if package:has_tool(toolkind, "clang", "clangxx") then
                        package:add("deps", "libomp")
                    end
                end
            end
        end
    end)

    on_fetch(function (package)
        local libomp = package:dep("libomp")
        if libomp and not libomp:fetch() then
            return
        end
        local result = {}
        if package.has_tool then
            for _, toolkind in ipairs({"cc", "cxx", "fc"}) do
                if toolkind == "cxx" then
                    flagname = "cxxflags"
                elseif toolkind == "fc" then
                    flagname = "fcflags"
                else
                    flagname = "cflags"
                end
                if package:has_tool(toolkind, "cl", "clang_cl") then
                    if package:config("feature") == "default" then
                        result[flagname] = "/openmp"
                    else
                        result[flagname] = "/openmp:" .. package:config("feature")
                    end
                    if package:has_tool(toolkind, "clang_cl") then
                        result.links = "libomp"
                    end
                elseif package:has_tool(toolkind, "clang", "clangxx") then
                    if package:is_plat("macosx") then
                        result[flagname] = "-Xpreprocessor -fopenmp"
                    else
                        result[flagname] = "-fopenmp"
                    end
                elseif package:has_tool(toolkind, "gcc", "gxx", "gfortran") then
                    result[flagname] = "-fopenmp"
                elseif package:has_tool(toolkind, "icc", "icpc", "ifort") then
                    result[flagname] = "-qopenmp"
                elseif package:has_tool(toolkind, "icl") then
                    result[flagname] = "-Qopenmp"
                end
            end
            for _, toolkind in ipairs({"ld", "fcld"}) do
                if package:config("runtime") == "default" then
                    if package:has_tool(toolkind, "clang", "clangxx") then
                        if not package:is_plat("macosx") then
                            result.ldflags = "-fopenmp"
                            result.shflags = "-fopenmp"
                        end
                    elseif package:has_tool(toolkind, "gcc", "gxx") then
                        result.ldflags = "-fopenmp"
                        result.shflags = "-fopenmp"
                    elseif package:has_tool(toolkind, "icc", "icpc") then
                        result.ldflags = "-qopenmp"
                        result.shflags = "-qopenmp"
                    elseif package:has_tool(toolkind, "icl") then
                        result.ldflags = "-Qopenmp"
                        result.shflags = "-Qopenmp"
                    elseif package:has_tool(toolkind, "gfortran") then
                        result.fcldflags = "-fopenmp"
                        result.fcshflags = "-fopenmp"
                    end
                end
                if package:config("runtime") == "custom" then
                    if package:has_tool(toolkind, "link") then
                        result.ldflags = "/nodefaultlib:vcomp"
                        result.shflags = "/nodefaultlib:vcomp"
                    end
                end
            end
        else
            raise("This package(openmp) requires xmake version 2.6.1 or newer.")
        end
        return (result.cflags or result.cxxflags or result.fcflags) and result
    end)

    on_install("linux", "macosx", "windows", "mingw@msys", function (package)
        -- we need not install anything because we need only compiler flags and deps
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
        #include <stdio.h>
        #include <omp.h>
        #ifndef _OPENMP
        #    error missing openmp flags
        #endif
        static void test() {
            #pragma omp parallel
            {
                printf("hello %d\n", omp_get_thread_num());
            }
        }
        ]]}))
    end)
