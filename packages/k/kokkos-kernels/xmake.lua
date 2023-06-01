package("kokkos-kernels")

    set_homepage("https://github.com/kokkos/kokkos-kernels")
    set_description("Kokkos C++ Performance Portability Programming EcoSystem: Math Kernels")
    set_license("Apache-2.0")

    add_urls("https://github.com/kokkos/kokkos-kernels/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kokkos/kokkos-kernels.git")
    add_versions("4.0.01", "3f493fcb0244b26858ceb911be64092fbf7785616ad62c81abde0ea1ce86688a")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    add_deps("cmake")
    on_load("windows|x64", "macosx", "linux", function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
            package:add("deps", "kokkos", {configs = {cuda = true}})
        else
            package:add("deps", "kokkos")
        end
    end)

    on_install("windows|x64", "macosx", "linux", function (package)
        if package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            if tonumber(vs) < 2022 then
                raise("Your compiler is too old to use this library.")
            end
        end
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("cuda") then
            table.insert(configs, "-DKokkosKernels_REQUIRE_DEVICES=CUDA")
        end
        import("package.tools.cmake").install(package, configs, {buildir = path.join(os.tmpdir(), "kk-build")})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Kokkos_Core.hpp>
            #include <KokkosSparse_MatrixPrec.hpp>
            #include <KokkosSparse_IOUtils.hpp>
            void test() {
                using EXSP = Kokkos::DefaultExecutionSpace;
                using MESP = typename EXSP::memory_space;
                using CRS = KokkosSparse::CrsMatrix<double, int, Kokkos::Device<EXSP, MESP>, void, int>;

                Kokkos::initialize();
                CRS A = KokkosSparse::Impl::kk_generate_diag_matrix<CRS>(1000);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
