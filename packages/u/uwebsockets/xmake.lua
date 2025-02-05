package("uwebsockets")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/uNetworking")
    set_description("Simple, secure & standards compliant web server for the most demanding of applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/uNetworking/uWebSockets/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uNetworking/uWebSockets.git")

    add_versions("v20.72.0", "ee15b503e85fcfd6d3e7f67e229bf8ffaee521a1fbdb6224a04265aaec4ea5c3")
    add_versions("v20.70.0", "39a7e32182df2da02955ab1c1681af9710c82115075f4caabb8689a2c04460b9")
    add_versions("v20.67.0", "8124bb46326f81d99ad3552b7a3bf78489784d3660fb60d7fe5f5337a21203a3")
    add_versions("v20.66.0", "54d1a8cfb46e1814e1525e9bc72a4652aa708f352e55f35ef4b55804c98bfee1")
    add_versions("v20.65.0", "e261f7c124b3b9e217fc766d6e51d4fdc4b227aa52c7a0ca5952a9e65cea4213")
    add_versions("v20.64.0", "bb81fa773dcbd6bc738904ad496554fd131a33269570e0e86fa09213d82ba9ef")
    add_versions("v20.62.0", "03dfc8037cf43856a41e64bbc7fc5a7cf5e6369c9158682753074ecbbe09eed1")
    add_versions("v20.61.0", "94778209571f832740fe1a4f19dbc059990b6acc34b8789f39cda6a158178d1f")
    add_versions("v20.60.0", "eb72223768f93d40038181653ee5b59a53736448a6ff4e8924fd56b2fcdc00db")

    add_configs("zip", {description = "Enable libzip", default = false, type = "boolean"})
    add_configs("deflate", {description = "Enable libdeflate", default = false, type = "boolean"})

    add_deps("usockets")

    on_load(function (package)
        if package:config("zip") then
            package:add("deps", "libzip")
            if package:config("deflate") then
                package:add("deps", "libdeflate")
                package:add("defines", "UWS_USE_LIBDEFLATE")
            end
        else
            package:add("defines", "UWS_NO_ZLIB")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cp("src/*", package:installdir("include/uwebsockets"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(){
                struct UserData {};
                uWS::App().get("/hello/:name", [](auto *res, auto *req) {
                    res->writeStatus("200 OK");
                       res->writeHeader("Content-Type", "text/html; charset=utf-8");
                       res->write("<h1>Hello ");
                       res->write(req->getParameter("name"));
                       res->end("!</h1>");
                }).ws<UserData>("/*", {
                    .open = [](auto *ws) {
                        ws->subscribe("oh_interesting_subject");
                    },
                    .message = [](auto *ws, std::string_view message, uWS::OpCode opCode) {
                        ws->send(message, opCode);
                    }
                }).listen(9001, [](auto *listenSocket) {
                    if (listenSocket) {
                        std::cout << "Listening on port " << 9001 << std::endl;
                    } else {
                        std::cout << "Failed to load certs or to bind to port" << std::endl;
                    }
                }).run();
            }
        ]]}, {configs = {languages = "cxx20"}, includes = "uwebsockets/App.h"}))
    end)
