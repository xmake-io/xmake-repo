add_rules("mode.debug", "mode.release")

add_requires("ceres-solver 2.1.0", {configs = {suitesparse = true}})
add_requires("abseil", "cairo", "eigen", "glog", "lua", "zlib")
add_requires("protobuf-cpp 3.19.4")

target("cartographer")
    set_kind("$(kind)")
    set_languages("cxx17")

    add_packages(
        "abseil",
        "ceres-solver", 
        "cairo", 
        "eigen",
        "glog",
        "lua",
        "zlib"
    )
    
    add_packages("protobuf-cpp", {public = true})
    add_rules("protobuf.cpp")

    add_files("cartographer/**.proto", {proto_rootdir = "cartographer", proto_autogendir = path.join("$(buildir)", "proto") , proto_public = true})
    
    add_includedirs("$(buildir)/proto/cartographer")
    add_includedirs("$(buildir)/proto", { public = true })

    add_headerfiles("$(buildir)/proto/(cartographer/**.h)")
    add_headerfiles("$(buildir)/proto/cartographer/(**.h)")

    remove_files("cartographer/**_service.proto")

    add_headerfiles("(cartographer/**.h)")
    add_files("cartographer/**.cc")

    remove_files("cartographer/io/serialization_format_migration.cc")
    remove_headerfiles("cartographer/io/serialization_format_migration.h")

    remove_files("cartographer/io/internal/pbstream_migrate.cc", "cartographer/io/internal/pbstream_info.cc")
    remove_headerfiles("cartographer/io/internal/pbstream_migrate.h", "cartographer/io/internal/pbstream_info.h")

    remove_headerfiles("**/fake_*.h", "**/*test*.h", "**/mock*.h")
    remove_files("**/fake_*.cc", "**/mock*.cc", "**/*_main.cc", "**/*test*.cc")

    -- BUILD_GRPC is not enabled
    remove_headerfiles("cartographer/cloud/**.h")
    remove_files("cartographer/cloud/**.cc")
    remove_files("cartographer/cloud/proto/**.proto")

    add_includedirs(".", { public = true })

    if is_plat("windows") then
        add_defines("NOMINMAX")
    end
