package("magnum-integration")

    set_homepage("https://magnum.graphics/")
    set_description("Integration libraries for magnum, Light­weight and mod­u­lar C++11/C++14 graph­ics mid­dle­ware for games and data visu­al­iz­a­tion.")
    set_license("MIT")

    add_urls("https://github.com/mosra/magnum-integration/archive/refs/tags/$(version).zip",
             "https://github.com/mosra/magnum-integration.git")
    add_versions("v2020.06", "8e5d7ffc9df300eb9fac9cff24e74d40f9a13f5e952bd3185fb002d4d6ac38ed")

    local integrations = {"bullet", "dart", "eigen", "glm", "imgui", "ovr"}
    for _, integration in ipairs(integrations) do
        add_configs(integration, {description = "Build " .. integration .. " integration library.", default = (integration == "imgui"), type = "boolean"})
    end

    add_deps("cmake", "magnum")
    on_load("windows", "linux", "macosx", function (package)
        local configdeps = {bullet = "bullet3",
                            eigen = "eigen3",
                            glm = "glm",
                            imgui = "imgui"}
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTS=OFF", "-DLIB_SUFFIX="}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        for _, integration in ipairs(integrations) do
            table.insert(configs, "-DWITH_" .. integration:upper() .. "=" .. (package:config(integration) and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto year = MAGNUMINTEGRATION_VERSION_YEAR;
                auto month = MAGNUMINTEGRATION_VERSION_MONTH;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Magnum/versionIntegration.h"}))
    end)
