package("field3d")

    set_homepage("https://sites.google.com/site/field3d/")
    set_description("Field3D is an open source library for storing voxel data.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/imageworks/Field3D/archive/refs/tags/$(version).tar.gz")
    add_versions("v1.7.3", "b6168bc27abe0f5e9b8d01af7794b3268ae301ac72b753712df93125d51a0fd4")

    add_patches("v1.7.3", path.join(os.scriptdir(), "patches", "1.7.3", "msvc.patch"), "330d067c39f084218925667a420e24c38e13fcb1663623218b17ed616bb1ca0e")

    add_deps("boost", {configs = {regex = true, thread = true}})
    add_deps("hdf5", "openexr 2.x")

    if is_plat("windows") then
        add_defines("WIN32")
        add_syslinks("shlwapi")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FIELD3D_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        if package:is_plat("windows") then
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            if tonumber(vs) < 2019 then
                raise("Your compiler is too old to use this library.")
            end
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++14")
            add_requires("boost", {configs = {regex = true, thread = true}})
            add_requires("hdf5", "openexr 2.x")
            target("Field3D")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_packages("boost", "hdf5", "openexr")
                add_includedirs("export", "include")
                add_headerfiles("export/*.h", "include/*.h", {prefixdir = "Field3D"})
                add_defines("H5_USE_110_API")
                if is_plat("windows") then
                    add_defines("WIN32")
                    add_syslinks("shlwapi")
                    if is_kind("static") then
                        add_defines("FIELD3D_STATIC")
                    else
                        add_defines("FIELD3D_EXPORT")
                    end
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Field3D::V3i res(100, 100, 100);
                Field3D::DenseFieldf::Ptr field(new Field3D::DenseFieldf);
                field->setSize(res);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Field3D/DenseField.h"}))
    end)
