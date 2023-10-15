package("openmp")

    set_homepage("https://openmp.org/")
    set_description("The OpenMP API specification for parallel programming")

    add_configs("runtime",      {description = "Set OpenMP runtime for gcc/clang like compilers.", default = "default", type = "string", values = {"default", "custom"}})
    add_configs("experimental", {description = "Enable experimental OpenMP feature for msvc.", default = false, type = boolean})

    on_load(function (package)
        if package.has_tool then
            for _, toolkind in ipairs({"cc", "cxx"}) do
                if package:config("runtime") == "default" then
                    if package:has_tool(toolkind, "clang", "clangxx") then
                        package:add("deps", "libomp")
                    end
                end
            end
        end
    end)

    on_fetch(function (package)
        for _, dep in ipairs(package:orderdeps()) do
            if not dep:fetch() then
                return
            end
        end
        local result = {}
        if package.has_tool then
            for _, toolkind in ipairs({"cc", "cxx"}) do
                local flagname = toolkind == "cxx" and "cxxflags" or "cflags"
                if package:has_tool(toolkind, "cl") then
                    result[flagname] = (package:config("experimental") and "/openmp:experimental" or "/openmp")
                elseif package:has_tool(toolkind, "clang_cl") then
                    result[flagname] = "-Xclang" .. (package:config("experimental") and "/openmp:experimental" or "/openmp")
                elseif package:has_tool(toolkind, "clang", "clangxx") then
                    if package:is_plat("macosx") then
                        result[flagname] = "-Xpreprocessor -fopenmp"
                    else
                        result[flagname] = "-fopenmp"
                    end
                elseif package:has_tool(toolkind, "gcc", "gxx") then
                    result[flagname] = "-fopenmp"
                elseif package:has_tool(toolkind, "icc", "icpc") then
                    result[flagname] = "-qopenmp"
                elseif package:has_tool(toolkind, "icl") then
                    result[flagname] = "-Qopenmp"
                end
                if package:config("runtime") == "default" then
                    if package:has_tool(toolkind, "clang", "clangxx") then
                        if not package:is_plat("macosx") then
                            result.ldflags = "-fopenmp"
                        end
                    elseif package:has_tool(toolkind, "gcc", "gxx") then
                        result.ldflags = "-fopenmp"
                    elseif package:has_tool(toolkind, "icc", "icpc") then
                        result.ldflags = "-qopenmp"
                    elseif package:has_tool(toolkind, "icl") then
                        result.ldflags = "-Qopenmp"
                    end
                end
                if package:config("runtime") == "custom" then
                    if package:has_tool(toolkind, "cl") then
                        result.ldflags = "/nodefaultlib:vcomp"
                    end
                end
            end
        else
            raise("This package(openmp) requires xmake version 2.6.1 or newer.")
        end
        return (result.cflags or result.cxxflags) and result
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
