package("openmp")

    set_homepage("https://openmp.org/")
    set_description("The OpenMP API specification for parallel programming")

    on_load(function (package)
        if package.has_tool then
            for _, toolkind in ipairs({"cc", "cxx"}) do
                local flagname = toolkind == "cxx" and "cxxflags" or "cflags"
                if package:has_tool(toolkind, "cl") then
                    package:add(flagname, "/openmp")
                elseif package:has_tool(toolkind, "clang", "clangxx") then
                    if package:is_plat("macosx") then
                        package:add(flagname, "-Xpreprocessor -fopenmp")
                    else
                        package:add(flagname, "-fopenmp")
                    end
                elseif package:has_tool(toolkind, "gcc", "gxx") then
                    package:add(flagname, "-fopenmp")
                elseif package:has_tool(toolkind, "icc", "icpc") then
                    package:add(flagname, "-qopenmp")
                elseif package:has_tool(toolkind, "icl") then
                    package:add(flagname, "-Qopenmp")
                end
            end
        end
        if package:is_plat("macosx", "linux") then
            package:add("deps", "libomp")
        end
    end)

    on_fetch(function (package)
        for _, dep in ipairs(package:orderdeps()) do
            if not dep:fetch() then
                return
            end
        end
        return {}
    end)

    on_install(function (package)
        -- we need not install anything because we need only compiler flags and deps
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
        #include <stdio.h>
        #include <omp.h>

        static void test() {
            #pragma omp parallel
            {
                printf("hello %d\n", omp_get_thread_num());
            }
        }
        ]]}))
    end)
