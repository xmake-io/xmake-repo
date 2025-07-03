package("intelrdfpmathlib")
    set_homepage("https://www.intel.com/content/www/us/en/developer/articles/tool/intel-decimal-floating-point-math-library.html")
    set_description("Intel(R) Decimal Floating-Point Math Library")

    add_urls("https://github.com/xmake-mirror/IntelRDFPMathLib.git")
    add_urls("http://www.netlib.org/misc/intel/IntelRDFPMathLib$(version).tar.gz", {
        alias = "intel",
        version = function (version)
            return format("%d0U%d", version:major(), version:minor())
        end
    })

    add_versions("intel:v2.3", "13f6924b2ed71df9b137a7df98706a0dcc3b43c283a0e32f8b6eadca4305136a")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if on_check then
        on_check(function (package)
            if package:is_arch("arm.*") then
                raise("package(intelrdfpmathlib) unsupported arm")
            end
        end)
    end

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bid_to_dpd32", {includes = {
            "intelrdfpmathlib/bid_conf.h",
            "intelrdfpmathlib/bid_functions.h"
        }}))
    end)
