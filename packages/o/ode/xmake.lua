package("ode")
    set_homepage("http://ode.org/")
    set_description("ODE is an open source, high performance library for simulating rigid body dynamics.")
    set_license("BSD-3-Clause")

    -- Windows arm64 will only be able to get the master version
    -- until a new release with a working windows arm64 build is
    -- published!
    if is_plat("windows") and is_arch("arm64") then  
        set_urls("https://github.com/odedevs/ode.git")  
        add_versions("master", "master")  
    else
        add_urls("https://bitbucket.org/odedevs/ode/get/$(version).zip")
        add_versions("0.16.6", "a6845f79fb401995de1fa1882d067e6803c0cc3a755a5fb0a28874a5182d89d6")
        add_versions("0.16.2", "000a5cdd0a81811cade2b0409ec06911a95e3c4c0d72a4cce3af6131115d0350")
    end

    add_configs("libccd", {description = "Build with libccd.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("user32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DODE_WITH_DEMOS=OFF", "-DODE_WITH_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("libccd") then
            table.insert(configs, "-DODE_WITH_LIBCCD=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dInitODE", {includes = "ode/odeinit.h"}))
    end)
