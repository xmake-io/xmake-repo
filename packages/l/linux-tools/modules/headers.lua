function load(package)
end

function install(package)
    os.vrunv("make", {"headers_install", "INSTALL_HDR_PATH=" .. package:installdir()})
end

function test(package)
    assert(package:has_cincludes("linux/version.h"))
end
