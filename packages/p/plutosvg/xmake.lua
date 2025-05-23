package("plutosvg")
    set_homepage("https://github.com/sammycage/plutosvg")
    set_description("Tiny SVG rendering library in C")
    set_license("MIT")

    add_urls("https://github.com/sammycage/plutosvg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sammycage/plutosvg.git")

    add_versions("v0.0.7", "78561b571ac224030cdc450ca2986b4de915c2ba7616004a6d71a379bffd15f3")
    add_versions("v0.0.6", "01f8aee511bd587a602a166642a96522cc9522efd1e38c2d00e4fbc0aa22d7a0")
    add_versions("v0.0.5", "b82fa5e361d841a8c1c3471060d9b87148169d5401592c23be5084cfb3b825b5")
    add_versions("v0.0.4", "1fd07a15f701a045afa8cb3d2709709180b0d27edbb8f366322c74084684d215")
    add_versions("v0.0.3", "ff44d903aa5faf751624ce797e42375e1f71381b532642b162a7c4e220e9cb97")
    add_versions("v0.0.2", "92f9e74d5b50f485c73192791e3f755023d1573e3e009adf8c7f837e4b318e82")

    add_deps("cmake")
    add_deps("plutovg")

    add_includedirs("include", "include/plutosvg")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "PLUTOSVG_BUILD_STATIC")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "FetchContent_MakeAvailable(plutovg)", "find_package(plutovg)", {plain = true})

        local configs = {"-DPLUTOSVG_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "plutosvg.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("plutosvg_document_load_from_file", {includes = "plutosvg/plutosvg.h"}))
    end)
