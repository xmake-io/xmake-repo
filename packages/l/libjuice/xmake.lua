package("libjuice")
    set_homepage("https://github.com/paullouisageneau/libjuice")
    set_description("JUICE is a UDP Interactive Connectivity Establishment library")
    set_license("MPL-2.0")

    add_urls("https://github.com/paullouisageneau/libjuice/archive/refs/tags/$(version).tar.gz",
             "https://github.com/paullouisageneau/libjuice.git")

    add_versions("v1.7.0", "a510c7df90d82731d1d5e32e32205d3370ec2e62d6230ffe7b19b0f3c1acabf2")
    add_versions("v1.6.2", "5078176d55042f3ccf3999c2556d84903f7edf80177ce4a7bf59507541e93938")
    add_versions("v1.6.1", "14d7cfc1a541843c1678828ad52d860d043bd82ed39ff076b260565796e4e4ee")

    add_configs("nettle", {description = "Use Nettle for hash functions", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "bcrypt")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("nettle") then
            package:add("deps", "nettle")
        end

        if not package:config("shared") and package:is_plat("windows", "mingw") then
            package:add("defines", "JUICE_STATIC")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})

        local configs = {
            "-DNO_TESTS=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_NETTLE=" .. (package:config("nettle") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("juice_create", {includes = "juice/juice.h"}))
    end)
