package("mdns")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mjansson/mdns")
    set_description("Public domain mDNS/DNS-SD library in C")

    add_urls("https://github.com/mjansson/mdns/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mjansson/mdns.git")
    add_versions("1.4.2", "c69cfdebe28a489c85f33744f7811c40572a9769a81cd57ecc09ef95802347f2")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("iphlpapi", "ws2_32")
    end

    on_install(function (package)
        local configs = {"-DMDNS_BUILD_EXAMPLE=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mdns_query_answer_multicast", {includes = "mdns.h"}))
    end)
