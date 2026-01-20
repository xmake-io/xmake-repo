package("c4core")
    set_homepage("https://github.com/biojppm/c4core")
    set_description("C++ utilities")
    set_license("MIT")

    add_urls("https://github.com/biojppm/c4core/releases/download/v$(version)/c4core-$(version)-src.zip",
             "https://github.com/biojppm/c4core.git")

    add_versions("0.2.7", "84cb22610ee822a3ce50927c4b290693fcbcc37dbabc446f15fd15903af314e0")
    add_versions("0.2.6", "4dbb64c0d1450a05af427541959f4117b6951b560df91cfead4c3b3ed88c9634")
    add_versions("0.2.5", "3d87765a612d72182d161f0bea401adf6f0df1c65fba54fb7f0727fa8585d0d2")
    add_versions("0.2.2", "5a9508385daa5b2608ed007784d76586af21c5367411efe9ae26d5b4aea03305")
    add_versions("0.2.1", "81ff1c0d15e24da6d76fdd1b6fdd903fa23d0df7c82e564f993147a4dac88773")

    add_configs("fast_float", {description = "use fastfloat to parse floats", default = false, type = "boolean"})
    add_configs("debugbreak", {description = "use debug break in debug builds", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("fast_float") then
            package:add("deps", "fast_float")
        else
            package:add("defines", "C4CORE_NO_FAST_FLOAT")
        end
        if package:config("debugbreak") then
            package:add("deps", "debugbreak")
        else
            package:add("defines", "C4_NO_DEBUG_BREAK")
        end

        if package:config("fast_float") or package:config("debugbreak") then
            package:add("patches", ">=0.2.1", "patches/0.2.1/cmake-deps.patch", "92c0c6510cc3b8cbd10b575b5b9d0defa2a19d19f24c1618a73d4f4636da4c9b")
        end
    end)

    on_install(function (package)
        if package:config("fast_float") then
            io.replace("src/c4/ext/fast_float.hpp", "c4/ext/fast_float_all.h", "fast_float/fast_float.h", {plain = true})
        end
        if package:config("debugbreak") then
            io.replace("src/c4/error.hpp", "c4/ext/debugbreak/debugbreak.h", "debugbreak.h", {plain = true})
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DC4CORE_WITH_FASTFLOAT=" .. (package:config("fast_float") and "ON" or "OFF"))
        table.insert(configs, "-DC4CORE_NO_DEBUG_BREAK=" .. (package:config("debugbreak") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "debugbreak"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                double value;
                c4::from_chars("52.4354", &value);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "c4/charconv.hpp"}))
    end)
