add_rules("mode.debug", "mode.release")

add_requires("boost", {configs = {iostreams = true}})
add_requires("ceres-solver", {configs = {suitesparse = true}})
add_requires("cairo", "eigen", "lua", "protobuf-cpp")

target("cartographer")
    set_kind("$(kind)")
    set_languages("cxx11")

    add_packages(
        "boost", 
        "ceres-solver", 
        "cairo", 
        "eigen", 
        "lua"
    )
    add_packages("protobuf-cpp", {public = true})
    add_rules("protobuf.cpp")

    add_files("cartographer/**.proto", {proto_autogendir = path.join(os.projectdir(), "build", "proto"), proto_public = true})
    remove_files("cartographer/**_service.proto")
    
    add_headerfiles("$(buildir)/proto/cartographer/**.h")
    add_files("$(buildir)/proto/cartographer/**.cc")
    add_includedirs("$(buildir)/proto")

    add_headerfiles("(cartographer/**.h)")
    add_files("cartographer/**.cc")

    remove_headerfiles("**/fake_*.h", "**/*test_helpers*.h", "**/mock*.h")
    remove_files("**/fake_*.cc", "**/*test_helpers*.cc", "**/mock*.cc", "**/*_main.cc", "**/*_test.cc")

    -- BUILD_GRPC is not enabled
    remove_headerfiles("cartographer/cloud/**.h")
    remove_files("cartographer/cloud/**.cc")
    remove_files("cartographer/cloud/proto/**.proto")

    add_includedirs(".")