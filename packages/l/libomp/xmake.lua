package("libomp")

    set_homepage("https://openmp.llvm.org/")
    set_description("LLVM's OpenMP runtime library.")

    set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/openmp-$(version).src.tar.xz")
    add_versions("10.0.1", "d19f728c8e04fb1e94566c8d76aef50ec926cd2f95ef3bf1e0a5de4909b28b44")
    add_versions("11.1.0", "d187483b75b39acb3ff8ea1b7d98524d95322e3cb148842957e9b0fbb866052e")
    add_versions("12.0.1", "60fe79440eaa9ebf583a6ea7f81501310388c02754dbe7dc210776014d06b091")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    on_fetch("macosx", "linux", function (package, opt)
        if opt.system then
            return package:find_package("system::omp", {includes = "omp.h"})
        end
    end)

    add_deps("cmake")

    add_links("omp")
    if is_plat("macosx") then
        add_extsources("brew::libomp")
    elseif is_plat("linux") then
        add_extsources("apt::libomp-dev")
        add_syslinks("pthread", "dl")
    end

    on_install("macosx", "linux", "cross", function (package)
        local configs = {"-DLIBOMP_INSTALL_ALIASES=OFF"}
        local shared = package:config("shared")
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (shared and "ON" or "OFF"))
        table.insert(configs, "-DLIBOMP_ENABLE_SHARED=" .. (shared and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("omp_get_thread_num", {includes = "omp.h"}))
    end)
