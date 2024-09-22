package("amrex")
    set_homepage("https://amrex-codes.github.io/amrex")
    set_description("AMReX: Software Framework for Block Structured AMR")

    add_urls("https://github.com/AMReX-Codes/amrex/releases/download/$(version)/amrex-$(version).tar.gz",
             "https://github.com/AMReX-Codes/amrex.git")

    add_versions("24.09", "a1435d16532d04a1facce9a9ae35d68a57f7cd21a5f22a6590bde3c265ea1449")

    add_patches("24.09", "patches/24.09/remove-symlink.patch", "d71adb07252e488ee003f6f04fea756864d6af2232b43208c9e138e062eb6e4d")

    add_configs("openmp", {description = "Enable OpenMP", default = false, type = "boolean"})
    add_configs("mpi", {description = "Enable MPI", default = false, type = "boolean", readonly = true})
    add_configs("cuda", {description = "Enable CUDA", default = false, type = "boolean"})
    add_configs("hdf5", {description = "Enable HDF5-based I/O", default = false, type = "boolean"})
    add_configs("fortran", {description = "Enable fortran", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            import("core.base.semver")

            local msvc = package:toolchain("msvc")
            if msvc then
                local vs_sdkver = msvc:config("vs_sdkver")
                assert(vs_sdkver and semver.match(vs_sdkver):gt("10.0.19041"), "package(amrex) require vs_sdkver > 10.0.19041.0")
            end
        end)
    end

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("hdf5") then
            package:add("deps", "hdf5")
        end
        if package:config("fortran") and package:is_plat("linux", "macosx") then
            package:add("deps", "gfortran", {kind = "binary"})
        end
    end)

    on_install("windows", "macosx", "linux", "bsd", "mingw", function (package)
        local configs = {"-DAMReX_ENABLE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DAMReX_PIC=" .. (package:config("pic") and "ON" or "OFF"))

        local configs_map = {
            openmp = "OMP",
            tools = "PLOTFILE_TOOLS",
        }
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                local real = configs_map[name] or name:upper()
                local enabled = (package:config(name) and "ON" or "OFF")
                table.insert(configs, format("-DAMReX_%s=%s", real, enabled))
            end
        end

        if package:is_plat("windows") then
            os.mkdir(path.join(package:buildir(), "Src/pdb"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <AMReX.H>
            #include <AMReX_Print.H>

            void test(int argc, char* argv[]) {
                amrex::Initialize(argc,argv);
                {
                    amrex::Print() << "Hello world from AMReX version " << amrex::Version() << "\n";
                }
                amrex::Finalize();
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
