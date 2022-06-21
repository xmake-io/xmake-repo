package("git-crypt")
    set_homepage("https://www.agwa.name/projects/git-crypt/")
    set_description("Transparent file encryption in git")

    add_urls("https://github.com/AGWA/git-crypt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AGWA/git-crypt.git")
    add_versions("0.7.0", "2210a89588169ae9a54988c7fdd9717333f0c6053ff704d335631a387bd3bcff")

    on_load(function (package)
        if is_plat("linux") then 
            local name = linuxos.name()
            if name == "ubuntu" or name == "debian" then 
                package:add("extsources", "apt::libssl-dev")
            elseif name == "centos"or name == "RHEL" then
                package:add("extsources", "apt::openssl-devel")
            end
        elseif is_plat("macosx") then 
            package:add("extsources", "apt::libssl-dev")
        end
        package:add("deps", "openssl")
    end)
    
    on_install(function (package)
        import("package.tools.make").install(package, configs)
    end)

    on_test(function (package)
        -- assert(package:has_cfuncs("foo", {includes = "foo.h"}))
    end)
