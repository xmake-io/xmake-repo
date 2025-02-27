package("tinycthread")
	set_homepage("https://github.com/tinycthread/tinycthread")
    set_description("A small, portable implementation of the C11 threads API.")
    set_license("MIT")

    add_urls("https://github.com/tinycthread/tinycthread.git")

    add_versions("2016.09.30", "6957fc8383d6c7db25b60b8c849b29caab1caaee")

    if is_plat("linux", "bsd", "cross") then
        add_syslinks("pthread")
    end

	on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("tinycthread")
                set_kind("$(kind)")
                add_files("source/*.c")
                add_headerfiles("source/*.h")

                if is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            int thread_entrypoint(void* arg) {
                (void) arg;
                return 0;
            }
            void test() {
                thrd_t t;
                if (thrd_create(&t, thread_entrypoint, (void*)0) == thrd_success) {
                    thrd_join(t, NULL);
                }
            }
        ]]}, {includes = {"tinycthread.h"}}))
    end)
