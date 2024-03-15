package("adaptivecpp")
    set_homepage("https://adaptivecpp.github.io/")
    set_description("Implementation of SYCL and C++ standard parallelism for CPUs and GPUs from all vendors: The independent, community-driven compiler for C++-based heterogeneous programming models. Lets applications adapt themselves to all the hardware in the system - even at runtime!")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AdaptiveCpp/AdaptiveCpp.git")

    add_versions("v24.02.0", "180bdcbf40db9907ba5b3da06a57e779e1527c62528211f72e9d36a5e46b0956")

    add_deps("cmake")
    add_deps("boost", {configs = {fiber = true, context = true}})

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("CL/sycl.hpp"))
    end)
