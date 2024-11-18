package("libcanberra")

    set_homepage("https://0pointer.de/lennart/projects/libcanberra/")
    set_description("libcanberra is an implementation of the XDG Sound Theme and Name Specifications")
    set_license("LGPL-2.1")

    add_urls("http://0pointer.de/lennart/projects/libcanberra/libcanberra-$(version).tar.xz")
    add_versions("0.30", "c2b671e67e0c288a69fc33dc1b6f1b534d07882c2aceed37004bf48c601afa72")

    add_deps("libtool", {kind = "library"})
    add_deps("autoconf", "automake", "m4")
    add_deps("libogg", "alsa-lib")

    if is_plat("linux") then
        add_syslinks("dl")
    end

    add_links("canberra", "canberra-null", "canberra-alsa", "canberra-oss", "canberra-pulse", "canberra-multi")

    add_linkdirs("lib", "lib/libcanberra-0.30")

    add_includedirs("include")

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "libvorbis", {configs = {shared = true}})
        else
            package:add("deps", "libvorbis")
        end
    end)

    on_install("linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-lynx"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--with-systemdsystemunitdir=" .. package:installdir("system_servise"))
        table.insert(configs, "LIBS=" .. "-lltdl -ldl")
        import("package.tools.autoconf").install(package, configs, {packagedeps= {"libtool", "libvorbis"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ca_context_create", {includes = "canberra.h"}))
    end)
