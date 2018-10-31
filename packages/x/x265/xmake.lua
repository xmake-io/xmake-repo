package("x265")

    set_homepage("http://x265.org")
    set_description("A free software library and application for encoding video streams into the H.265/MPEG-H HEVC compression format.")

    add_urls("https://bitbucket.org/multicoreware/x265/downloads/x265_$(version).tar.gz")

    add_versions("2.9", "ebae687c84a39f54b995417c52a2fdde65a4e2e7ebac5730d251471304b91024")

    add_deps("cmake", "nasm")

    on_install("linux", "macosx", function (package)
        os.cd("build/linux")
        os.vrun("./multilib.sh")
        os.cp("8bit/libx265.a", package:installdir("lib"))
        os.cp("8bit/x265_config.h", package:installdir("include"))
        os.cp("../../source/x265.h", package:installdir("include"))
    end)
