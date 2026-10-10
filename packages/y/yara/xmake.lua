package("yara")
    set_homepage("https://virustotal.github.io/yara/")
    set_description("The pattern matching swiss knife")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/VirusTotal/yara/archive/refs/tags/v$(version).tar.gz")

    add_versions("4.5.8", "c322414975ff6f701149856613afdcd92a7e6939c284c798ae3c85618197efaa")

    add_deps("openssl3")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("yr_initialize", {includes = "yara.h"}))
        assert(package:has_cfuncs("yr_rules_scan_mem", {includes = "yara.h"}))
    end)
