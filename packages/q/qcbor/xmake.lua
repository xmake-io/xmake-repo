package("qcbor")
    set_homepage("https://github.com/laurencelundblade/QCBOR")
    set_description("Comprehensive, powerful, commercial-quality CBOR encoder/ decoder that is still suited for small devices.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/laurencelundblade/QCBOR/archive/refs/tags/$(version).tar.gz",
             "https://github.com/laurencelundblade/QCBOR.git")

    add_versions("v1.4.1", "c7ef031b60b23bf8ede47c66c9713982bba2608668b144280a65665bfcc94470")

    add_configs("float_hw_use", {description = "Eliminate dependency on FP hardware and FP instructions", default = false, type = "boolean"})
    add_configs("float_preferred", {description = "Eliminate support for half-precision and CBOR preferred serialization", default = false, type = "boolean"})
    add_configs("float_all", {description = "Eliminate floating-point support completely", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DQCBOR_OPT_DISABLE_FLOAT_HW_USE=" .. (package:config("float_hw_use") and "OFF" or "ON"))
        table.insert(configs, "-DQCBOR_OPT_DISABLE_FLOAT_PREFERRED=" .. (package:config("float_preferred") and "OFF" or "ON"))
        table.insert(configs, "-DQCBOR_OPT_DISABLE_FLOAT_ALL=" .. (package:config("float_all") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("QCBOREncode_Init", {includes = "qcbor/qcbor_encode.h"}))
    end)
