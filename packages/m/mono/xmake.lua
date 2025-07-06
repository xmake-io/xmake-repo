package("mono")
    set_homepage("https://www.mono-project.com/")
    set_description("Cross platform, open source .NET development framework")

    set_urls("https://download.mono-project.com/sources/mono/mono-$(version).tar.xz",
             {version = function (version) return version:gsub("%+", ".") end})

    add_versions("6.12.0+199", "c0850d545353a6ba2238d45f0914490c6a14a0017f151d3905b558f033478ef5")
    add_versions("6.8.0+123", "e2e42d36e19f083fc0d82f6c02f7db80611d69767112af353df2f279744a2ac5")

    add_includedirs("include/mono-2.0")

    add_deps("cmake", "python 3.x", {kind = "binary"})
    add_deps("autotools")

    on_install("!windows", function (package)
        local configs = {"--disable-silent-rules", "--enable-nls=no"}
        for _, CMakeLists in ipairs(os.files("**.txt")) do
            local CMakeLists_content = io.readfile(CMakeLists)
            io.writefile(CMakeLists, [[set(CMAKE_POLICY_VERSION_MINIMUM "3.5")
]] .. CMakeLists_content)
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mono_object_get_class", {includes = "mono/metadata/object.h"}))
    end)
