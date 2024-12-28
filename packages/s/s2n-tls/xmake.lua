package("s2n-tls")
    set_homepage("https://aws.github.io/s2n-tls/doxygen/s2n_8h.html")
    set_description("An implementation of the TLS/SSL protocols")
    set_license("Apache-2.0")

    add_urls("https://github.com/aws/s2n-tls/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aws/s2n-tls.git")

    add_versions("v1.5.10", "6f13d37658954cc24f4eb8c7f30736e026ce06f8c9609f7820ab82504618a98d")
    add_versions("v1.5.9", "8a9aa2ba9a25f936e241eaa6bb7e39bc1a097d178c4b255fa36795c0457e3f4e")
    add_versions("v1.5.7", "c30b97c8bcccc0557331dd1a043010a70984c9cff11b0bbd769651db68f8b91d")
    add_versions("v1.5.6", "85602d0ad672cb233052504624dec23b47fc6d324bb82bd6eaff13b8f652dec3")
    add_versions("v1.5.5", "6316e1ad2c8ef5807519758bb159d314b9fef31d79ae27bc8f809104b978bb04")
    add_versions("v1.5.1", "d79710d6ef089097a3b84fc1e5cec2f08d1ec46e93b1d400df59fcfc859e15a3")
    add_versions("v1.5.0", "5e86d97d8f24653ef3dff3abe6165169f0ba59cdf52b5264987125bba070174d")
    add_versions("v1.4.18", "a55b0b87eaaffc58bd44d90c5bf7903d11be816aa144296193e7d1a6bea5910e")
    add_versions("v1.4.17", "5235cd2c926b89ae795b1e6b5158dce598c9e79120208b4bcd8d19ce04d86986")
    add_versions("v1.4.16", "84fdbaa894c722bf13cac87b8579f494c1c2d66de642e5e6104638fddea76ad9")
    add_versions("v1.4.14", "90cd0b7b1e5ebc7e40ba5f810cc24a4d604aa534fac7260dee19a35678e38659")
    add_versions("v1.4.12", "d0769f27eb9e6b8fc98d3e8e3eb87ed71e10b08fade87893b293878d84faaceb")
    add_versions("v1.4.3", "e42551bdf6595f718e232eb98c4f0e37c7a284f29bfcbc09fa9c0a2145754ab9")
    add_versions("v1.3.51", "75c650493c42dddafd5dec6a42f2258ab52e501719ee5a337ec580cc958ea67a")

    add_configs("pq", {description = [[Enables all Post Quantum Crypto code. You likely want this
    for older compilers or uncommon platforms.]], default = false, type = "boolean"})
    add_configs("pq_asm", {description = [[Turns on the ASM for PQ Crypto even if it's available for the toolchain. You likely want this on older compilers.]], default = false, type = "boolean"})
    add_configs("stacktrace", {description = [[Enables stacktrace functionality in s2n-tls. Note that this functionality is
    only available on platforms that support execinfo.]], default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("cmake", "openssl")

    on_install("linux", "bsd", "cross", "android", function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DUNSAFE_TREAT_WARNINGS_AS_ERRORS=OFF",
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DS2N_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DS2N_NO_PQ=" .. (package:config("pq") and "OFF" or "ON"))
        table.insert(configs, "-DS2N_NO_PQ_ASM=" .. (package:config("pq_asm") and "OFF" or "ON"))
        table.insert(configs, "-DS2N_STACKTRACE=" .. (package:config("stacktrace") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("s2n_connection_new", {includes = "s2n.h"}))
    end)
