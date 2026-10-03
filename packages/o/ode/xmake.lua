package("ode")
    set_homepage("https://ode.org/")
    set_description("ODE is an open source, high performance library for simulating rigid body dynamics.")
    set_license("BSD-3-Clause")

    local function parse_version(version)
        local commits = {
            ["0.16.6"] = "a5fc0bc282703ab34d7d3d2500bafae7428eeaa9"
        }
        return commits[tostring(version)]
    end

    add_urls("https://bitbucket.org/odedevs/ode/get/$(version).tar.gz", {version = parse_version})
    add_versions("0.16.6", "05c0a0ea84c58c213d05e220adbc6559c473227505d5668a51493eed21b6c2f8")

    add_configs("libccd", {description = "Build with libccd.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("user32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows|!arm*", "macosx", "linux", function (package)
        local configs = {"-DODE_WITH_DEMOS=OFF", "-DODE_WITH_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("libccd") then
            table.insert(configs, "-DODE_WITH_LIBCCD=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dInitODE", {includes = "ode/odeinit.h"}))
    end)
