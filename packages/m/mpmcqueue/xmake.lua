package("mpmcqueue")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rigtorp/MPMCQueue")
    set_description("A bounded multi-producer multi-consumer concurrent queue written in C++11")
    set_license("MIT")

    add_urls("https://github.com/rigtorp/MPMCQueue/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rigtorp/MPMCQueue.git")
    add_versions("v1.0", "f009ef10b66f2b8bc6e3a4f50577efbdfea0c163464cd7de368378f173007b75")

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", [[if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
	if (MSVC)
		add_compile_options(/permissive- /W4 /wd4172 /wd4324 /wd4530)
	else()
		add_compile_options(-Wall -Wextra -Wpedantic)
	endif()

	find_package(Threads REQUIRED)

	add_executable(MPMCQueueExample src/MPMCQueueExample.cpp)
	target_link_libraries(MPMCQueueExample MPMCQueue Threads::Threads)

	add_executable(MPMCQueueTest src/MPMCQueueTest.cpp)
	target_link_libraries(MPMCQueueTest MPMCQueue Threads::Threads)

	enable_testing()
	add_test(MPMCQueueTest MPMCQueueTest)
endif()]], "", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("rigtorp::mpmc::Queue<int>", {configs = {languages = "c++14"}, includes = "rigtorp/MPMCQueue.h"}))
    end)
