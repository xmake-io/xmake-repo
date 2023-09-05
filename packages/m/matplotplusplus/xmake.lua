package("matplotplusplus")

    set_homepage("https://alandefreitas.github.io/matplotplusplus/")
    set_description("A C++ Graphics Library for Data Visualization")
    set_license("MIT")

    add_urls("https://github.com/alandefreitas/matplotplusplus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alandefreitas/matplotplusplus.git")
    add_versions("v1.1.0", "5c3a1bdfee12f5c11fd194361040fe4760f57e334523ac125ec22b2cb03f27bb")

    local configdeps = {jpeg   = "libjpeg-turbo",
                        tiff   = "libtiff",
                        zlib   = "zlib",
                        png    = "libpng",
                        blas   = "openblas",
                        fftw   = "fftw",
                        opencv = "opencv"}
    for config, dep in pairs(configdeps) do
        add_configs(config, {description = "Enable " .. config .. " support.", default = (config == "zlib"), type = "boolean"})
    end
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("nodesoup")
    if is_plat("windows") then
        add_syslinks("user32", "shell32", "gdi32")
    end
    on_load("windows", "macosx", "linux", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            if tonumber(vs) < 2019 then
                raise("Your compiler is too old to use this library.")
            end
        end
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTS=OFF", "-DBUILD_INSTALLER=ON", "-DBUILD_PACKAGE=OFF", "-DWITH_SYSTEM_NODESOUP=ON"}
        for config, dep in pairs(configdeps) do
            if not package:config(config) then
                table.insert(configs, "-DCMAKE_DISABLE_FIND_PACKAGE_" .. config:upper() .. "=ON")
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cmath>
            #include <vector>
            void test() {
                using namespace matplot;
                std::vector<double> x = linspace(0, 2 * pi);
                std::vector<double> y = transform(x, [](auto x) { return sin(x); });
                plot(x, y, "-o");
                show();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "matplot/matplot.h"}))
    end)
