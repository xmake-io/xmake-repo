package("standardlib")
    set_kind("library", {headeronly = true})    
    set_homepage("https://github.com/gregoryc/standardlib")
    set_description("A complete standardlib for c for once")
    set_license("Public Domain")

    add_urls("https://github.com/gregoryc/standardlib.git")
    add_versions("2024.03.25", "d27a1293ccfe7ef04a961806754c5d1272614b72")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if not package:has_cincludes("threads.h", {configs = {languages = "c11"}}) then
            package:add("defines", "FOUNDATIONAL_LIB_THREAD_FUNCTIONS_ENABLED=0")
        end
    end)

    on_install("linux", "bsd", "cross", "mingw", function (package)
        os.cp("foundationallib.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <foundationallib.h>
            #include <stdio.h>
            void test() {
                const char *text = "This is a sample text";
                const char *suffix = "text";
                printf("Does the string end with \"%s\"? %s\n", suffix, ends_with(text, suffix) ? "Yes" : "No");
            }
        ]]}, {configs = {languages = "c20"}}))
    end)
