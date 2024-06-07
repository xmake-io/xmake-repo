package("uwebsockets")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/uNetworking")
    set_description("Simple, secure & standards compliant web server for the most demanding of applications.")
    set_license("Apache-2.0")

    add_urls("https://github.com/uNetworking/uWebSockets/archive/refs/tags/$(version).tar.gz",
             "https://github.com/uNetworking/uWebSockets.git")

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
