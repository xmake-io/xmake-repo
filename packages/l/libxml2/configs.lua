local libxml2_configs = {
    catalog      = {"Add the Catalog support",                true },
    -- debug        = {"Add the debugging module",               true },
    html         = {"Add the HTML support",                   true },
    http         = {"Add the HTTP support",                   false},
    iconv        = {"Add ICONV support",                      false},
    icu          = {"Add ICU support",                        false},
    iso8859x     = {"Add ISO8859X support if no iconv",       true },
    legacy       = {"Add deprecated APIs for compatibility",  false},
    lzma         = {"Use liblzma",                            false},
    modules      = {"Add the dynamic modules support",        true },
    output       = {"Add the serialization support",          true },
    pattern      = {"Add the xmlPattern selection interface", true },
    programs     = {"Build programs",                         false},
    push         = {"Add the PUSH parser interfaces",         true },
    python       = {"Build Python bindings",                  false},
    readline     = {"readline support for xmllint shell",     false},
    regexps      = {"Add Regular Expressions support",        true },
    sax1         = {"Add the older SAX1 interface",           true },
    threads      = {"Add multithread support",                true },
    tls          = {"Enable thread-local storage",            false},
    valid        = {"Add the DTD validation support",         true },
    xpath        = {"Add the XPATH support",                  true },
    zlib         = {"Use libz",                               false},

    c14n         = {"Add the Canonicalization support",    true },
    history      = {"history support for xmllint shell",   false},
    reader       = {"Add the xmlReader parsing interface", true },
    schemas      = {"Add Relax-NG and Schemas support",    true },
    schematron   = {"Add Schematron support",              true },
    thread_alloc = {"Add per-thread malloc hooks",         false},
    writer       = {"Add the xmlWriter saving interface",  true },
    xinclude     = {"Add the XInclude support",            true },
    xptr         = {"Add the XPointer support",            true },
}

function get_libxml2_configs()
    return libxml2_configs
end
