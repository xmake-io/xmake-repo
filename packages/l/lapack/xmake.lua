package("lapack")
    set_homepage("https://netlib.org/lapack/")
    set_description("LAPACK--Linear Algebra Package is a standard software library for numerical linear algebra")

    add_urls("https://github.com/Reference-LAPACK/lapack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Reference-LAPACK/lapack.git")

    add_versions("v3.12.0", "eac9570f8e0ad6f30ce4b963f4f033f0f643e7c3912fc9ee6cd99120675ad48b")

    if is_plat("linux") then
        add_extsources("apt::liblapack-dev")
    end

    add_deps("cmake", "gfortran")

    add_links( "lapacke", "lapack", "cblas", "blas")

    on_install("linux", function (package)
        local configs = {"-DLAPACKE=ON", "-DBUILD_TESTING=OFF", "-DCBLAS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cblas_snrm2", {includes = "cblas.h"}))
        assert(package:has_cfuncs("LAPACKE_dsyev", {includes = "lapacke_utils.h"}))
    end)
