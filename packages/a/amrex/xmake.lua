package("amrex")
    set_homepage("https://amrex-codes.github.io/amrex")
    set_description("AMReX: Software Framework for Block Structured AMR")

    add_urls("https://github.com/AMReX-Codes/amrex/releases/download/$(version)/amrex-$(version).tar.gz",
             "https://github.com/AMReX-Codes/amrex.git")

    add_versions("26.02", "7627f0bac4f8025b555b6c7c7a26e2d4db4e7a7fda660b77b272ffe40749b7b2")
    add_versions("26.01", "b26c8d36b3941881bb5db683147f94d5a48f9bcedfa4bcf65a36acb6f0710bcb")
    add_versions("25.11", "be9e5f04e1f3e2252a14e5bb817fb4f2c231e0901ef85ee4e14341616f6b1ba6")
    add_versions("25.09", "9c288e502c98a9ebf62c9f46081ecd65703ad49bd8b3eaf17939146cf442163a")
    add_versions("25.08", "6e903fd02e72a3d23b438ec257a96a5a948ac07200220669ab8ff16ff047bde6")
    add_versions("25.06", "2f69c708ddeaba6d4be3a12ab6951f171952f6f7948e628c5148d667c4197838")
    add_versions("25.05", "d80ae0b4ccb26696fcd3c04d96838592fd0043be25fceebd82cd165f809b1a5d")
    add_versions("25.04", "71c3f01a9cfbf3aff7f0a5dd66c2ac99a606334f1910052194c2520df3f7b7be")
    add_versions("25.03", "7a2dc60d01619afdcbce0ff624a3c1a5a605e28dd8721c0fbec638076228cab0")
    add_versions("25.02", "2680a5a9afba04e211cd48d27799c5a25abbb36c6c3d2b6c13cd4757c7176b23")
    add_versions("24.12", "ca4b41ac73fabb9cf3600b530c9823eb3625f337d9b7b9699c1089e81c67fc67")
    add_versions("24.09", "a1435d16532d04a1facce9a9ae35d68a57f7cd21a5f22a6590bde3c265ea1449")

    add_patches(">=24.09", "patches/24.09/remove-symlink.patch", "d71adb07252e488ee003f6f04fea756864d6af2232b43208c9e138e062eb6e4d")

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

    on_install("windows", "macosx", "linux", "bsd", "mingw", "msys", function (package)
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
