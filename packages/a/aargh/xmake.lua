package("aargh")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ilyabrin/aargh")
    set_description("Single-header command-line argument parser for C99 (argh.h)")
    set_license("MIT")

    add_urls("https://github.com/ilyabrin/aargh/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/ilyabrin/aargh.git")
    add_versions("1.9.0", "f7161aab3c73e07b7db354c40af24e299ab5681cedd4fef54cecd72ba9ee9e7f")

    -- include/aargh keeps it apart from the argh package, which also has an argh.h
    add_includedirs("include/aargh")

    on_install(function (package)
        os.cp("argh.h", package:installdir("include/aargh"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #define ARGH_IMPLEMENTATION
            #include <argh.h>
            void test(int argc, char **argv) {
                int jobs = 1;
                argh_parser p;
                argh_init(&p, "test", NULL);
                argh_int(&p, 'j', "jobs", &jobs, "Parallel jobs");
                argh_parse(&p, argc, argv);
            }
        ]]}, {configs = {languages = "c99"}}))
    end)
