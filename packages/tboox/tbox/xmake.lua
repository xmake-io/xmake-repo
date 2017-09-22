package("tboox.tbox")

    set_homepage("http://www.tboox.org")
    set_description("A glib-like multi-platform c library")

    add_urls("https://github.com/tboox/tbox/archive/$(version).tar.gz", {alias = "github"})
    add_urls("https://coding.net/u/waruqi/p/tbox/git/archive/$(version).zip", {alias = "coding"})
    add_urls("https://github.com/tboox/tbox.git")
    add_urls("https://gitee.com/tboox/tbox.git")

    set_versions("v1.6.2")
    add_sha256s("github@v1.6.2", "5236090b80374b812c136c7fe6b8c694418cbfc9c0a820ec2ba35ff553078c7b")
    add_sha256s("coding@v1.6.2", "0881b08a88722cc35e7613d9785768d4d7ae4656b134da5653f8a125fc72497e")


