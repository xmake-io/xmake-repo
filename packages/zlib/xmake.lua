package "zlib"

    set_homepage        "http://www.zlib.net"
    set_description     "A Massively Spiffy Yet Delicately Unobtrusive Compression Library"
    set_url             "http://zlib.net/zlib-$(version).tar.gz"
    set_mirror          "https://downloads.sourceforge.net/project/libpng/zlib/$(version)/zlib-$(version).tar.gz"
    set_versions        ("1.2.10", "1.2.11")
    set_sha256s         ("c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
                         "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1")

    -- TODO 
    on_build(function (package)
    end)

    -- TODO 
    on_install(function (package)
    end)

    -- TODO 
    on_test(function (package)
    end)
