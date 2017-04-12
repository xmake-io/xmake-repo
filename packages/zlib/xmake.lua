package("zlib")

    set_homepage("http://www.zlib.net")
    set_description("A Massively Spiffy Yet Delicately Unobtrusive Compression Library")
    
    set_url("http://zlib.net/zlib-$(version).tar.gz")
    set_mirror("https://downloads.sourceforge.net/project/libpng/zlib/$(version)/zlib-$(version).tar.gz")

    set_versions("1.2.10", "1.2.11")

    -- on build
    on_build(function ()
       -- TODO 
    end)

    -- on install
    on_install(function ()
       -- TODO 
    end)

    -- on test
    on_test(function ()
       -- TODO 
    end)
