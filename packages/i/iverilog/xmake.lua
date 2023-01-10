package("iverilog")
    set_kind("toolchain")
    set_homepage("https://steveicarus.github.io/iverilog/")
    set_description("Icarus Verilog")

    add_urls("https://github.com/steveicarus/iverilog.git")
    add_versions("2023.1.7", "45bd0968c3d6d5b96a7ac7c2c1b0557cc229e568")

    add_deps("autoconf", "automake", "libtool", "flex", "bison", "gperf")

    on_install("mingw@msys", "macosx", "linux", function (package)
        local configs = {}
        os.vrunv("sh", {"./autoconf.sh"})
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        io.writefile("hello.vl", [[
            module main();
            initial
              begin
                $display("Hi there");
                $finish ;
              end
            endmodule]])
	    os.vrunv("iverilog", {"hello.vl"})
    end)
