package("tinycthread")
	set_homepage("https://github.com/tinycthread/tinycthread")
    set_description("A small, portable implementation of the C11 threads API.")
    set_license("MIT")

    add_urls("https://github.com/tinycthread/tinycthread.git")

	on_install("windows", "linux", "macos", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinycthread")
                set_kind("static")
                add_files("source/*.c")
                add_headerfiles("source/*.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_ctypes("thrd_t", {configs = {languages = "c11"}, includes = "tinycthread.h"}))
    end)
