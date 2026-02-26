package("glm")
    set_homepage("https://glm.g-truc.net/")
    set_description("OpenGL Mathematics (GLM)")
    set_license("MIT")

    add_urls("https://github.com/g-truc/glm/archive/refs/tags/$(version).tar.gz", 
             {version = function(version) return version:gsub("%+", ".") end})
    add_urls("https://github.com/g-truc/glm.git")

    add_versions("1.0.3", "6775e47231a446fd086d660ecc18bcd076531cfedd912fbd66e576b118607001")
    add_versions("1.0.2", "19edf2e860297efab1c74950e6076bf4dad9de483826bc95e2e0f2c758a43f65")
    add_versions("1.0.1", "9f3174561fd26904b23f0db5e560971cbf9b3cbda0b280f04d5c379d03bf234c")
    add_versions("1.0.0", "e51f6c89ff33b7cfb19daafb215f293d106cd900f8d681b9b1295312ccadbd23")
    add_versions("0.9.9+8", "7d508ab72cb5d43227a3711420f06ff99b0a0cb63ee2f93631b162bfe1fe9592")

    add_configs("header_only", {description = "Use header only version.", default = true, type = "boolean"})
    add_configs("cxx_standard", {description = "Select c++ standard to build.", default = "14", type = "string", values = {"98", "11", "14", "17", "20"}})
    add_configs("modules", {description = "Build with C++20 modules support.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("modules") then
            package:config_set("header_only", false)
            package:config_set("cxx_standard", "20")
        elseif package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        else
            package:add("deps", "cmake")
        end
    end)

    on_install(function (package)
        if not package:config("modules") then
            if package:config("header_only") then
                os.cp("glm", package:installdir("include"))
            else
                io.replace("CMakeLists.txt", "NOT GLM_DISABLE_AUTO_DETECTION", "FALSE")
                local configs = {"-DGLM_BUILD_TESTS=OFF"}
                table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
                table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
                table.insert(configs, "-DCMAKE_CXX_STANDARD=" .. package:config("cxx_standard"))
                import("package.tools.cmake").install(package, configs)
            end
        else
            io.writefile("xmake.lua", [[ 
                target("glm")
                    set_kind("$(kind)")
                    set_languages("c++20")
                    add_headerfiles("./(glm/**.hpp)")
                    add_headerfiles("./(glm/**.h)")
                    add_headerfiles("./(glm/**.inl)")
                    add_includedirs(".")
                    add_files("glm/**.cpp")
                    add_files("glm/**.cppm", {public = true})
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        local cxx_standard = "c++" .. package:config("cxx_standard")
        assert(package:check_cxxsnippets({test = [[
            #include <glm/glm.hpp>
            #include <glm/ext/matrix_clip_space.hpp>
            void test() {
                glm::mat4 proj = glm::perspective(glm::radians(45.f), 1.33f, 0.1f, 10.f);
            }
        ]]}, {configs = {languages = cxx_standard}}))
    end)
