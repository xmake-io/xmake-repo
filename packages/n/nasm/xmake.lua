package("nasm")

    set_kind("binary")
    set_homepage("https://www.nasm.us/")
    set_description("Netwide Assembler (NASM) is an 80x86 assembler.")

    add_urls("https://www.nasm.us/pub/nasm/releasebuilds/$(version)/nasm-$(version).tar.xz",
             "https://repo.or.cz/nasm.git")
    add_versions("2.13.03", "812ecfb0dcbc5bd409aaa8f61c7de94c5b8752a7b00c632883d15b2ed6452573")

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)
