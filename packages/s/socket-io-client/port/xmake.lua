option("version", {description = "The sioclient version."})

add_rules("mode.debug", "mode.release")

add_requires("websocketpp", "rapidjson", "openssl", "asio")

target("sioclient")
    set_kind("$(kind)")
    set_languages("cxx11")
    add_files("src/*.cpp", "src/internal/*.cpp")
    add_headerfiles("src/*.h")
    add_defines("VERSION=\"$(version)\"")
    add_packages("rapidjson", "websocketpp", "asio", "openssl")

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all", {export_classes = true})
    end
