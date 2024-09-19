local libxml2_configs = {
    catalog  = "Add the Catalog support",
    -- debug    = "Add the debugging module",
    html     = "Add the HTML support",
    http     = "Add the HTTP support",
    iconv    = "Add ICONV support",
    icu      = "Add ICU support",
    iso8859x = "Add ISO8859X support if no iconv",
    legacy   = "Add deprecated APIs for compatibility",
    lzma     = "Use liblzma",
    modules  = "Add the dynamic modules support",
    output   = "Add the serialization support",
    pattern  = "Add the xmlPattern selection interface",
    programs = "Build programs",
    push     = "Add the PUSH parser interfaces",
    python   = "Build Python bindings",
    readline = "readline support for xmllint shell",
    regexps  = "Add Regular Expressions support",
    sax1     = "Add the older SAX1 interface",
    threads  = "Add multithread support",
    tls      = "Enable thread-local storage",
    valid    = "Add the DTD validation support",
    xpath    = "Add the XPATH support",
    zlib     = "Use libz",

    c14n = "Add the Canonicalization support",
    history = "history support for xmllint shell",
    reader = "Add the xmlReader parsing interface",
    schemas = "Add Relax-NG and Schemas support",
    schematron = "Add Schematron support",
    thread_alloc = "Add per-thread malloc hooks",
    writer = "Add the xmlWriter saving interface",
    xinclude = "Add the XInclude support",
    xptr = "Add the XPointer support",
}

function get_libxml2_configs()
    return libxml2_configs
end
