package("managedc")
    set_kind("library", { headeronly = true })
    set_description("Reference counter garabage collection for C")

    add_urls("https://github.com/Frityet/ManagedC.git")
    add_versions("1.5.0", "f4cce9c1aee952d603c18b73dc6219ea15b91717")

    on_install(function (package)
        os.cp("src/*.h", package:installdir("include"))
    end)

    on_test(function (package)
         assert(package:check_csnippets({test = [[
            #include <stdio.h>
            void test() {
                void* data = mc_alloc_managed(0, 0, 0);
                printf("data: %p\n", data);
            }
        ]]}, {configs = {languages = "c11"}, includes = "managed.h"}))
    end)


