package("openmp")

    set_homepage("https://openmp.org/")
    set_description("The OpenMP API specification for parallel programming")

    add_configs("runtime",      {description = "Set OpenMP runtime for gcc/clang like compilers.", default = "default", type = "string", values = {"default", "custom"}})
    add_configs("experimental", {description = "Enable experimental OpenMP feature for msvc.", default = true, type = boolean})

    on_load(function (package)
        if package.has_tool then
            for _, toolkind in ipairs({"cc", "cxx"}) do
                local flagname = toolkind == "cxx" and "cxxflags" or "cflags"
                if package:has_tool(toolkind, "cl") then
                    package:add(flagname, (package:config("experimental") and "/openmp:experimental" or "/openmp"))
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
                if package:config("runtime") == "default" then
                    if package:has_tool(toolkind, "cl") then
                        package:add("ldflags", "/openmp")
                    elseif package:has_tool(toolkind, "clang", "clangxx") then
                        if package:is_plat("macosx") then
                            package:add("deps", "libomp") -- need to tell apple clang from llvm clang
                        else
                            package:add("ldflags", "-fopenmp")
                        end
                    elseif package:has_tool(toolkind, "gcc", "gxx") then
                        package:add("ldflags", "-fopenmp")
                    elseif package:has_tool(toolkind, "icc", "icpc") then
                        package:add("ldflags", "-qopenmp")
                    elseif package:has_tool(toolkind, "icl") then
                        package:add("ldflags", "-Qopenmp")
                    end
                end
                if package:config("runtime") == "custom" then
                    if package:has_tool(toolkind, "cl") then
                        package:add("ldflags", "/openmp")
                        package:add("ldflags", "/nodefaultlib:vcomp")
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
        -- we need fetch the installed flags in on_load
        local manifest = package:manifest_load()
        if manifest then
            return manifest.vars
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
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
