package("libultrahdr")
	set_homepage("https://github.com/google/libultrahdr")
	set_description("Library for encoding and decoding UltraHDR images")
	set_license("Apache-2.0")

	add_urls("https://github.com/google/libultrahdr/archive/refs/tags/$(version).tar.gz",
			 "https://github.com/google/libultrahdr.git")

	add_versions("v1.4.0", "e7e1252e2c44d8ed6b99ee0f67a3caf2d8a61c43834b13b1c3cd485574c03ab9")
	add_patches("v1.4.0", "patches/1.4.0/install.patch", "9a8b62da3be97e24b6bc54e64b37f7440d3adbc5a6f9e6759d54a4be00a17095")

	add_configs("gles", {description = "Build with GPU acceleration.", default = false, type = "boolean"})

	add_deps("cmake", "libjpeg-turbo")

	if is_plat("linux", "bsd") then
		add_syslinks("pthread")
	end

	on_load(function (package)
		if package:config("shared") then
			package:add("defines", "UHDR_USING_SHARED_LIBRARY")
		end
	end)

	on_install("windows", "macosx", "linux", "mingw", "bsd", "android", function (package)
		local configs = {
			"-DUHDR_BUILD_EXAMPLES=OFF",
			"-DUHDR_BUILD_TESTS=OFF",
			"-DUHDR_BUILD_BENCHMARK=OFF",
			"-DUHDR_BUILD_FUZZERS=OFF",
			"-DUHDR_BUILD_JAVA=OFF",
			"-DUHDR_BUILD_PACKAGING=OFF",
			"-DUHDR_BUILD_DEPS=OFF",
			"-DUHDR_ENABLE_INSTALL=ON",
			"-DUHDR_ENABLE_GLES=" .. (package:config("gles") and "ON" or "OFF")
		}
		table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
		table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
		import("package.tools.cmake").install(package, configs)
	end)

	on_test(function (package)
		assert(package:has_cfuncs("uhdr_create_encoder", {includes = "ultrahdr_api.h"}))
	end)
