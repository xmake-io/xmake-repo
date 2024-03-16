package("rapidxml")
    set_kind("library", {headeronly = true})
    set_homepage("https://sourceforge.net/projects/rapidxml")
    set_description("An attempt to create the fastest XML parser possible")
    set_license("MIT")

    set_urls("https://sourceforge.net/projects/rapidxml/files/rapidxml/rapidxml%20$(version)/rapidxml-$(version).zip")

    add_versions("1.13", "c3f0b886374981bb20fabcf323d755db4be6dba42064599481da64a85f5b3571")

    on_install(function (package)
        os.vcp("**.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test() {
                rapidxml::xml_document<> doc;
                doc.parse<0>("");
            }
        ]]}, { includes = "rapidxml.hpp" }))
    end)
