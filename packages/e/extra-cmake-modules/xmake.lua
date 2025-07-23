package("extra-cmake-modules")
    set_homepage("https://invent.kde.org/frameworks/extra-cmake-modules")
    set_description("Extra CMake Modules (ECM) extends CMake with additional modules and scripts.")

    add_urls("https://invent.kde.org/frameworks/extra-cmake-modules/-/archive/v$(version)/extra-cmake-modules-$(version).tar.gz" , {alias = "gitlab"})
    add_urls("https://github.com/KDE/extra-cmake-modules/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_urls("https://github.com/KDE/extra-cmake-modules.git")

    add_versions("github:v6.10.0", "96970136cf38c810f4ef90a33ad4ef9c8977956e1a6a02a179b7abf3a8967b34")
    add_versions("gitlab:v6.10.0", "6025709712e075f06c3b9eebfffc50ce31605712d8947c748d9b2241e915f595")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::extra-cmake-modules")
    elseif is_plat("linux") then
        add_extsources("pacman::extra-cmake-modules", "apt::extra-cmake-modules")
    elseif is_plat("macosx") then
        add_extsources("brew::extra-cmake-modules")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_DOC=OFF", "-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(os.isfile(package:installdir("share", "ECM", "cmake", "ECMConfig.cmake")))
    end)
