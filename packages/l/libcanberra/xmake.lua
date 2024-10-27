package("libcanberra")

    set_homepage("https://0pointer.de/lennart/projects/libcanberra/")
    set_description("libcanberra is an implementation of the XDG Sound Theme and Name Specifications")
    set_license("LGPL-2.1")

    add_urls("http://0pointer.de/lennart/projects/libcanberra/libcanberra-$(version).tar.xz")
    add_versions("0.30", "c2b671e67e0c288a69fc33dc1b6f1b534d07882c2aceed37004bf48c601afa72")

    add_deps("libtool", {configs = {kind_libtool = library}})
    add_deps("autoconf", "automake", "m4")
    add_deps("libogg", "alsa-lib")

    add_deps("libvorbis", {configs = {shared=true}})

    if is_plat("linux") then
        add_syslinks("dl", "ltdl")
    end

    add_links("canberra", "canberra-null", "canberra-alsa", "canberra-oss", "canberra-pulse", "canberra-multi", "ltdl")

    add_linkdirs("lib", "lib/libcanberra-0.30")

    add_includedirs("include")

    on_install("linux", function (package)
        local fetchinfo = package:dep("libtool"):fetch()

        if package:config("shared") then
            package:add("deps", "libvorbis", {configs = {shared=true}})
        else
            package:add("deps", "libvorbis")
        end
        local configs = {"--disable-dependency-tracking", "--disable-lynx"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--with-systemdsystemunitdir=" .. package:installdir("system_servise"))
        table.insert(configs, "LDFLAGS=-L" .. fetchinfo.artifacts.installdir .. "/lib")
        table.insert(configs, "CPPFLAGS=-I" .. fetchinfo.artifacts.installdir .. "/include/")
        table.insert(configs, "LIBLTDL=" .. "-llibltdl")

        local pos = string.find(fetchinfo.artifacts.installdir, "libtool")
        local after_libtool = string.sub(fetchinfo.artifacts.installdir, pos + 7)
        local libtool_dir = "../../../libtool" .. after_libtool
        print(libtool_libdir)
        package:add("linkdirs", libtool_dir .. "/lib/")
        package:add("includedirs", libtool_dir .. "/include/")
        import("package.tools.autoconf").install(package, configs, {packagedeps= {"libvorbis"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ca_context_create", {includes = "canberra.h"}))
    end)
