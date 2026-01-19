package("fixed-containers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/teslamotors/fixed-containers")
    set_description("C++ Fixed Containers")
    set_license("MIT")

    add_urls("https://github.com/teslamotors/fixed-containers.git")
    add_versions("2025.12.10", "39f7c30b4fe333a792c58bbbc0ec3207c58ccbee")
    add_versions("2025.01.03", "b8e8427326b8f7d3485828488e59b5853cf8b6bf")

    add_deps("cmake", "magic_enum")

    on_install(function (package)
        io.replace("CMakeLists.txt", "install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include", [[install(DIRECTORY include/]], {plain = true})
        io.replace("CMakeLists.txt", "DESTINATION .)", [[DESTINATION include)]], {plain = true})
        local configs = {"-DBUILD_TESTS=OFF", "-DFIXED_CONTAINERS_OPT_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fixed_containers/comparison_chain.hpp>
            void test() {
                auto c = fixed_containers::ComparisonChain::start()
                    .compare(1, 1).compare(2, 2).compare(3, 3).compare(4, 4).compare(5, 5)
                    .is_equal();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
