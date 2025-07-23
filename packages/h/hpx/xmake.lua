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
        if package:config("context") or not is_arch("x86") then
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
        local configs = {"-DHPX_WITH_EXAMPLES=OFF", "-DHPX_WITH_TESTS=OFF", "-DHPX_WITH_UNITY_BUILD=OFF", "-DHPX_WITH_PKGCONFIG=ON"}
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
        -- https://hpx-docs.stellar-group.org/latest/html/manual/building_hpx.html#most-important-cmake-options
        -- `HPX_WITH_GENERIC_CONTEXT_COROUTINES` must be enabled for non-x86 architectures such as ARM and Power.
        if not is_arch("x86") then
            table.insert(configs, "-DHPX_WITH_GENERIC_CONTEXT_COROUTINES=ON")
        else
            table.insert(configs, "-DHPX_WITH_GENERIC_CONTEXT_COROUTINES=" .. (package:config("context") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        -- Get links from the generated .pc file
        local links = {}
        local link_set = {}
        local syslinks = {pthread = true, dl = true, rt = true}
        local pkgconfigdir = package:installdir("lib", "pkgconfig")
        for _, pcfile in ipairs(os.files(path.join(pkgconfigdir, "*.pc"))) do
            local content = io.readfile(pcfile)
            local libs_line = content:match("Libs:%s*(.-)\n")
            for token in libs_line:gmatch("%S+") do
                if token:startswith("-l") then
                    local link = token:sub(3)
                    -- Filter out syslinks, boost libs and existing libs
                    if not syslinks[link] and not link:startswith("Boost::") and not link_set[link] then
                        table.insert(links, link)
                        link_set[link] = true
                    end
                end
            end
        end

        if #links > 0 then
            package:add("links", "hpx_iostreams")
            package:add("links", links)
        else
            wprint("Failed to parse .pc file, using fallback links for hpx. If this fails, please submit an issue")
            package:add("links", "hpx", "hpx_iostreams", "hpx_core", "hpx_wrap", "hpx_init")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <hpx/iostream.hpp>
            #include <hpx/hpx_main.hpp>
            void test() {
                hpx::cout << "Hello World!\n" << std::flush;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
