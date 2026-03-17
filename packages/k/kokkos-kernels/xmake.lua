package("kokkos-kernels")
    set_homepage("https://github.com/kokkos/kokkos-kernels")
    set_description("Kokkos C++ Performance Portability Programming EcoSystem: Math Kernels")
    set_license("Apache-2.0")

    add_urls("https://github.com/kokkos/kokkos-kernels/archive/refs/tags/$(version).tar.gz",
             "https://github.com/kokkos/kokkos-kernels.git")

    add_versions("5.0.2", "bd7fc683bbbaa07a3db07419e480d7adcbe691d6ff3f76717e631b11592c0059")
    add_versions("5.0.0", "31a5b8b4b8a36bcc6a424a6f2ad9ccc111dc77304c3ccc735fd4597fba9a03e4")
    add_versions("4.6.00", "22c83eb31d9eed1bbc69d7bd6b3d4646395ff5e4bb50403dcadf98c76945562e")
    add_versions("4.4.00", "6559871c091eb5bcff53bae5a0f04f2298971d1aa1b2c135bd5a2dae3f9376a2")
    add_versions("4.3.01", "749553a6ea715ba1e56fa0b13b42866bb9880dba7a94e343eadf40d08c68fab8")
    add_versions("4.3.00", "03c3226ee97dbca4fa56fe69bc4eefa0673e23c37f2741943d9362424a63950e")
    add_versions("4.2.01", "058052b3a40f5d4e447b7ded5c480f1b0d4aa78373b0bc7e43804d0447c34ca8")
    add_versions("4.0.01", "3f493fcb0244b26858ceb911be64092fbf7785616ad62c81abde0ea1ce86688a")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(kokkos-kernels) require vs_toolset >= 14.3")
            end
        end)
    end

    on_load(function (package)
        local kokkos = "kokkos"
        local version = package:version()
        if version then
            kokkos = kokkos .. " " .. version
        end

        if package:config("cuda") then
            package:add("deps", "cuda")
            package:add("deps", kokkos, {configs = {cuda = true}})
        else
            package:add("deps", kokkos)
        end
    end)

    on_install("windows|x64", "macosx|x86_64", "linux", function (package)
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
        local opt = {buildir = path.join(os.tmpdir(), "kk-build")}
        if package:version():ge("4.7.0") and package:is_plat("windows") then
            opt.cxflags = "/bigobj"
        end
        import("package.tools.cmake").install(package, configs, opt)
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
        ]]}, {configs = {languages = package:version():ge("4.7.0") and "c++20" or "c++17"}}))
    end)
