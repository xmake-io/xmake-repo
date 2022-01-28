package("asn1c")
    set_kind("binary")
    set_homepage("http://lionet.info/asn1c/")
    set_description("The ASN.1 Compiler")

    add_urls("https://github.com/vlm/asn1c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vlm/asn1c.git")
    add_versions("v0.9.28", "56298523d53f6bb54d88a399fc8b711672e5d9059919b8198f658ba94b280125")

    add_deps("autoconf", "automake", "libtool")

    on_install("linux", "macosx", function (package)
        local configs = {
            "--disable-dependency-tracking",
            "--mandir=" .. package:installdir("man")
        }
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        io.writefile("test.asn1", [[
          MyModule DEFINITIONS ::=
          BEGIN
          MyTypes ::= SEQUENCE {
             myObjectId    OBJECT IDENTIFIER,
             mySeqOf       SEQUENCE OF MyInt,
             myBitString   BIT STRING {
                                  muxToken(0),
                                  modemToken(1)
                         }
          }
          MyInt ::= INTEGER (0..65535)
          END
        ]])
        os.vrun("asn1c test.asn1")
    end)
