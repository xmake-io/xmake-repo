package("libpcsclite")
    set_homepage("https://pcsclite.apdu.fr/")
    set_description("Middleware to access a smart card using SCard API (PC/SC).")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/LudovicRousseau/PCSC/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LudovicRousseau/PCSC.git")

    add_versions("2.4.1", "e7b6737f68c3b9a763fb0b0370d899cea091cced9d762ca8a6032c959576d5be")
    add_versions("2.3.3", "00b667aa71504ed1d39a48ad377de048c70dbe47229e8c48a3239ab62979c70f")

    add_configs("embedded", {description = "For embedded systems [limit RAM and CPU resources by disabling features (log)].", default = false, type = "boolean"})

    add_deps("meson", "ninja")
    add_includedirs("include/PCSC")
    on_install("linux", "bsd", "cross", function (package)
        io.replace("meson.build", "executable%s*%b()", "")
        io.replace("meson.build", "library%('pcscspy'.-%)", "")
        io.replace("meson.build", "run_command%('pod2man'.-%)", "")
        io.replace("meson.build", "install_data%('pcsc%-spy%.1',.-install_dir.-%b().-%)", "")
        io.replace("meson.build", [[gen_flex = generator(find_program('flex'),
  output : '@BASENAME@.c',
  arguments : ['-o', '@OUTPUT@', '--prefix=@BASENAME@', '@INPUT@'])]], "", {plain = true})
        io.replace("meson.build", [[gen_src = gen_flex.process('src/configfile.l', 'src/tokenparser.l')
pcscd_src += gen_src]], "", {plain = true})
        io.replace("meson.build", "doxygen.found()", "false", {plain = true})

        local configs = {
            '-Dlibsystemd=false',
            '-Dlibudev=false',
            '-Dpolkit=false'
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dembedded=" .. (package:config("embedded") and "true" or "false"))

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                SCARDCONTEXT hSC;
                SCardEstablishContext(SCARD_SCOPE_USER, 0, 0, &hSC);
            }
        ]]}, {configs = {languages = "c99"}, includes = "winscard.h"}))
    end)
