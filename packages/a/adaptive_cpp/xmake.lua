package("adaptive_cpp")

    set_kind("library")
    set_homepage("https://github.com/AdaptiveCpp/AdaptiveCpp")
    set_description("AdaptiveCpp (formerly hipSYCL) - an independent, multi-target implementation of SYCL and C++ standard parallelism for CPUs and GPUs")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v$(version).tar.gz")
    add_versions("25.10.0", "334b16ebff373bd2841f83332c2ae9a45ec192f2cf964d5fdfe94e1140776059")

    -- Replace upstream FetchContent of OpenCL-Headers/OpenCL-CLHPP with the
    -- xrepo packages (opencl-headers / opencl-clhpp), so no network fetch
    -- happens during cmake configure.
    add_patches("25.10.0", "patches/25.10.0/use-xrepo-opencl-headers.patch", "c7a646f4bd8d8b740f8f06dc9f09a296850183e71c2d11195dd1f80209ce36bc")

    ---------------------------------------------------------------------------
    -- AdaptiveCpp is a clang plugin: the plugin ABI requires the exact same
    -- clang that the `acpp` driver invokes on user code, so the whole host
    -- toolchain used at compile time is this LLVM. clang + lld + libomp are
    -- needed (SSCP compiler and the accelerated CPU backend); the LLVM
    -- runtimes are not (user code keeps the host libstdc++).
    -- LLVM 21.1.0: LLVM 18.x does not build with host GCC >= 15 and xrepo has
    -- no 19.x/20.x; AdaptiveCpp's own support matrix is LLVM 15-21, only its
    -- configure-time guard still flags 21 as untested (see on_install).
    ---------------------------------------------------------------------------
    add_deps("llvm 21.1.0", {host = true, kind = "library", private = true, configs = {clang = true, lld = true, openmp = true, ["compiler-rt"] = false, libcxx = false, libcxxabi = false, libunwind = false}})
    -- the `acpp` compiler driver is a python script
    add_deps("python 3.x", {kind = "binary"})

    add_configs("opencl", {description = "Enable the OpenCL (SPIR-V / SSCP) backend, e.g. for Intel/NVIDIA GPUs.", default = false, type = "boolean"})
    add_configs("cuda",   {description = "Enable the CUDA backend. Requires a CUDA toolkit already installed on the system.", default = false, type = "boolean"})
    add_configs("rocm",   {description = "Enable the ROCm/HIP backend. Requires a ROCm installation on the system.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("opencl") then
            package:add("deps", "opencl", "opencl-headers", "opencl-clhpp")
        end

        -- expose SYCL headers & runtime libraries to targets that add this
        -- package (paths are resolved relative to the package installdir)
        package:add("includedirs", path.join("include", "AdaptiveCpp"))
        package:add("linkdirs", "lib")
        package:add("links", "acpp-rt", "acpp-common")
        package:add("syslinks", "dl", "pthread")
        -- make `acpp` available on PATH for os.runv / rules in consumer projects
        package:addenv("PATH", "bin")
    end)

    on_install("linux", function (package)
        import("package.tools.cmake")

        local llvm = package:dep("llvm")
        local llvm_prefix = llvm:installdir()
        assert(os.isfile(path.join(llvm_prefix, "bin", "clang++")), "llvm dependency does not contain clang++!")

        local configs = {
            -- full profile: SSCP generic JIT compiler + stdpar + accelerated CPU
            "-DACPP_COMPILER_FEATURE_PROFILE=full",
            -- AdaptiveCpp 25.10.0 predates the LLVM 21 support of newer releases
            -- (its configure guard rejects LLVM > 20 as "not yet tested"), but
            -- it builds and works against LLVM 21.x with this official switch.
            "-DACPP_EXPERIMENTAL_LLVM=ON",
            "-DWITH_LEVEL_ZERO_BACKEND=OFF",
            "-DWITH_CUDA_BACKEND=" .. (package:config("cuda") and "ON" or "OFF"),
            "-DWITH_ROCM_BACKEND=" .. (package:config("rocm") and "ON" or "OFF"),
            "-DWITH_OPENCL_BACKEND=" .. (package:config("opencl") and "ON" or "OFF"),
            -- install the acpp config files into <prefix>/etc/AdaptiveCpp
            "-DACPP_CONFIG_FILE_GLOBAL_INSTALLATION=OFF",
            -- build the clang plugin against the xrepo LLVM
            "-DLLVM_DIR=" .. path.join(llvm_prefix, "lib", "cmake", "llvm")
        }

        if package:config("opencl") then
            table.insert(configs, "-DOpenCL_ROOT=" .. package:dep("opencl"):installdir())
            table.insert(configs, "-DACPP_OCL_HEADERS_INCLUDE_DIR=" .. package:dep("opencl-headers"):installdir("include"))
            table.insert(configs, "-DACPP_OCL_CLHPP_INCLUDE_DIR=" .. package:dep("opencl-clhpp"):installdir("include"))
        end

        if package:config("rocm") then
            table.insert(configs, "-DROCM_PATH=" .. (os.getenv("ROCM_PATH") or "/opt/rocm"))
        end

        cmake.install(package, configs)

        -- Rewire the default host CPU compiler to the bundled xrepo clang, so
        -- the installed package does not reference the build machine's system
        -- compiler (e.g. /usr/bin/g++). `acpp` also supports overriding it at
        -- runtime via ACPP_DEFAULT_CPU_CXX / --default-cpu-cxx.
        local clangxx = path.join(llvm_prefix, "bin", "clang++")
        -- clang adds -fopenmp to user links but no runpath, so the driver link
        -- lines get rpath flags for the LLVM lib dirs (LLVM >= 21 installs
        -- libomp into a target-triple subdirectory of lib).
        local llvm_libdirs = {path.join(llvm_prefix, "lib")}
        for _, libomp in ipairs(os.files(path.join(llvm_prefix, "lib", "*", "libomp.so"))) do
            table.insert(llvm_libdirs, 1, path.directory(libomp))
        end
        local rpaths = {}
        for _, dir in ipairs(llvm_libdirs) do
            table.insert(rpaths, "-Wl,-rpath," .. dir)
        end
        rpaths = table.concat(rpaths, " ")
        local corecfg = path.join(package:installdir("etc", "AdaptiveCpp"), "acpp-core.json")
        if os.isfile(corecfg) then
            io.gsub(corecfg, '"default%-cpu%-cxx"%s*:%s*"[^"]*"', string.format('"default-cpu-cxx" : "%s"', clangxx))
            io.gsub(corecfg, '"default%-omp%-link%-line"%s*:%s*"[^"]*"', string.format('"default-omp-link-line" : "-fopenmp %s"', rpaths))
            io.gsub(corecfg, '"default%-sequential%-link%-line"%s*:%s*"[^"]*"', string.format('"default-sequential-link-line" : "%s"', rpaths))
        end
    end)

    on_test(function (package)
        local acpp = path.join(package:installdir("bin"), "acpp")
        assert(os.isfile(acpp), "acpp driver not installed!")
        os.vrunv("python3", {acpp, "--version"})
    end)
