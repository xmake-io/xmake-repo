package("nodeeditor")
    set_homepage("https://github.com/paceholder/nodeeditor")
    set_description("Qt Node Editor. Dataflow programming framework")
    set_license("BSD-3")

    set_urls("https://github.com/paceholder/nodeeditor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/paceholder/nodeeditor.git")
    add_versions("3.0.11", "9810137d576d8d1049df29c0a8869a0dce4ae10636e3b042a841f5696f26187d")
    add_versions("2.1.3", "4e3194a04ac4a2a2bf4bc8eb6cc27d5cc154923143c1ecf579ce7f0115a90585")
    add_versions("2.2.2", "010ebcf9b68f676c81ea13ea4a541f7ba441ec3dc3b6508315c36f6466c13536")
    add_patches("2.1.3", path.join(os.scriptdir(), "patches", "2.1.3", "fix_qt.patch"), "11b6e765f8c8b0002f84ef0c3eb7dde23076b0564679760b7f4c8ba7c7e46887")
    add_patches("2.2.2", path.join(os.scriptdir(), "patches", "2.2.2", "fix_qt.patch"), "8c0efbf0883689f52d8f2bca2ae4deae9964311812c808b686a84f629f8bd66a")

    add_deps("cmake")

    on_load(function (package)
        package:add("deps", "qt5core", "qt5gui", "qt5widgets", {debug = package:is_debug()})
        if package:config("shared") then
            package:add("defines", "NODE_EDITOR_SHARED")
        else
            package:add("defines", "NODE_EDITOR_STATIC")
        end
    end)

    on_install("windows", "linux", "mingw", "macosx", function (package)
        local qt = package:dep("qt5core"):fetch().qtdir

        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if qt then
            table.insert(configs, "-DQt5_DIR=" .. path.join(qt.libdir, "cmake", "Qt5"))
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local cxflags
        if not package:is_plat("windows") then
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            void test() {
                QtNodes::FlowScene scene(std::make_shared<QtNodes::DataModelRegistry>());
                QtNodes::FlowView view(&scene);
            }
        ]]}, {configs = {languages = "c++14", cxflags = cxflags}, includes = {"nodes/FlowScene", "nodes/FlowView"}}))
    end)
