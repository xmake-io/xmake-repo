package("hpx")
    set_homepage("https://hpx.stellar-group.org")
    set_description("The C++ Standard Library for Parallelism and Concurrency")
    set_license("BSL-1.0")

    add_urls("https://github.com/STEllAR-GROUP/hpx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/STEllAR-GROUP/hpx.git")

    add_versions("v1.11.0", "01ec47228a2253b41e318bb09c83325a75021eb6ef3262400fbda30ac7389279")
    add_versions("v1.10.0", "5720ed7d2460fa0b57bd8cb74fa4f70593fe8675463897678160340526ec3c19")
    add_versions("v1.9.1", "1adae9d408388a723277290ddb33c699aa9ea72defadf3f12d4acc913a0ff22d")

    add_configs("malloc", {description = "Use a custom allocator", default = "system", type = "string", values = {"system", "tcmalloc", "jemalloc", "mimalloc"}})
    add_configs("cuda", {description = "Enable support for CUDA", default = false, type = "boolean"})
    add_configs("mpi", {description = "Enable the MPI parcelport", default = false, type = "boolean"})
    add_configs("tcp", {description = "Enable the TCP parcelport", default = false, type = "boolean"})
    add_configs("lci", {description = "Enable the LCI parcelport", default = false, type = "boolean"})
    add_configs("apex", {description = "Enable APEX integration", default = false, type = "boolean"})
    add_configs("context", {description = "Enable Boost. Context for task context switching", default = false, type = "boolean"})
    add_configs("cpu_count", {description = "Set the maximum CPU count supported by HPX", default = 64, type = "number"})

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "rt")
    end

    add_deps("cmake", "hwloc")

    on_load("windows", "linux", "macosx", function (package)
        local malloc = package:config("malloc")
        if malloc ~= "system" then
            package:add("deps", malloc)
        end

        local boost_libs = {
            thread = true,
            chrono = true,
            serialization = true,
            iostreams = true
        }
        if package:config("context") or not (is_plat("linux", "windows") and is_arch("x86", "x86_64", "x64")) then
            boost_libs.context = true
        end
        package:add("deps", "boost >=1.71.0", {configs = boost_libs})

        -- after v1.11.0, hpx adds macro guard to handle breaking changes in asio.
        if package:version():gt("1.11.0") then
            package:add("deps", "asio >=1.12.0")
        else
            package:add("deps", "asio >=1.12.0 <1.34.0")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DHPX_WITH_EXAMPLES=OFF", "-DHPX_WITH_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_MALLOC=" .. package:config("malloc"))
        table.insert(configs, "-DHPX_WITH_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_PARCELPORT_MPI=" .. (package:config("mpi") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_PARCELPORT_TCP=" .. (package:config("tcp") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_PARCELPORT_LCI=" .. (package:config("lci") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_APEX=" .. (package:config("apex") and "ON" or "OFF"))
        table.insert(configs, "-DHPX_WITH_MAX_CPU_COUNT=" .. package:config("cpu_count"))
        if not package:config("shared") then
            table.insert(configs, "-DHPX_WITH_STATIC_LINKING=ON")
        end
        -- On almost all platforms except Linux (x86) and Windows, HPX requires Boost.Context.
        -- https://hpx-docs.stellar-group.org/latest/html/manual/building_hpx.html#most-important-cmake-options
        -- See: https://github.com/STEllAR-GROUP/hpx/issues/4829
        if package:is_plat("linux", "windows") and package:is_arch("x86", "x86_64", "x64") then
            table.insert(configs, "-DHPX_WITH_GENERIC_CONTEXT_COROUTINES=" .. (package:config("context") and "ON" or "OFF"))
        else
            table.insert(configs, "-DHPX_WITH_GENERIC_CONTEXT_COROUTINES=ON")
        end
        import("package.tools.cmake").install(package, configs)

        package:add("includedirs", "include")
        package:add("linkdirs", "lib")

        if not package:config("shared") then
            -- static lib
            package:add("linkgroups",
                "hpx_core",
                "hpx_partitioned_vector",
                "hpx_unordered",
                "hpx_component_storage",
                "hpx_process",
                "hpx",
                "hpx_iostreams",
                {group = true}
            )
            cprint("\n${yellow}get links:")
            print(package:get("links"))
            cprint("\n${yellow}get linkgroups:")
            print(package:get("linkgroups"))
        else
            -- shared lib
            import("utils.binary.deplibs", {alias = "get_depend_libs"})
            import("core.base.graph")

            local hpx_libs_map = {}
            local lib_pattern = package:is_plat("windows") and "hpx*.dll" or "libhpx*.so"
            cprint('\n${red}Scanning for libraries in: %s', path.join(package:installdir(package:is_plat("windows") and "bin" or "lib"), lib_pattern))
            for _, libpath in ipairs(os.files(path.join(package:installdir(package:is_plat("windows") and "bin" or "lib"), lib_pattern))) do
                local linkname = package:is_plat("windows") and path.basename(libpath) or path.basename(libpath):sub(4)
                hpx_libs_map[linkname] = libpath
                cprint('${bright}Found library: libpath=%s, linkname=%s', libpath, linkname)
            end

            local dag = graph.new()
            local all_hpx_lib_paths = table.values(hpx_libs_map)
            for linkname, libpath in pairs(hpx_libs_map) do
                cprint("\n${bright underline}Analyzing dependencies for: %s", libpath)
                local dependencies = get_depend_libs(libpath, {
                    plat = package:plat(),
                    arch = package:arch(),
                    recursive = true,
                    resolve_path = true,
                    resolve_hint_paths = all_hpx_lib_paths
                })

                if dependencies then
                    for _, dep_path in ipairs(dependencies) do
                        cprint("  ${red} found dependencies = %s", dep_path)
                        local dep_basename = package:is_plat("windows") and path.basename(dep_path) or path.basename(dep_path)
                        local dep_linkname = package:is_plat("windows") and dep_basename or dep_basename:sub(4)
                        if hpx_libs_map[dep_linkname] then
                            cprint("  ${cyan}%s ${yellow}-> ${green}%s", linkname, dep_linkname)
                            dag:add_edge(linkname, dep_linkname)
                        end
                    end
                end
            end

            local sorted_links, has_cycle = dag:topo_sort()
            if has_cycle then
                os.raise("Cyclic dependency detected in HPX libraries")
            end

            cprint("\n${yellow}Topo-sorted dependency order (deps first):")
            print(sorted_links)

            package:add("links", sorted_links)

            cprint("\n${yellow}get links:")
            print(package:get("links"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <hpx/iostream.hpp>
            #include <hpx/hpx_main.hpp>
            int main() {
                hpx::cout << "Hello World!\n" << std::flush;
                return 0;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
