require "uri"
require "http"
require "json"
require "kemal"
require "base64"

module YouTube
    # ...
    # ...
end

module Spotify
    Client = HTTP::Client.new(URI.parse("https://api.spotify.com"))
    CREDS = Base64.encode("#{ENV["sID"]}:#{ENV["sSECRET"]}").gsub("\n", "")
end

get "/" { next "=D" }

get "/y/:res" do |env|
    payload = env.params.url.dup

    next URI.decode(payload["res"].to_s)
end

get "/s/:res/:id" do |env|
    payload = env.params.url.dup

    auth = JSON.parse(
        HTTP::Client.post(
            url: URI.parse("https://accounts.spotify.com/api/token"),
            headers: HTTP::Headers{"Authorization" => "Basic #{Spotify::CREDS}"},
            form: {"grant_type" => "client_credentials"}
        ).body
    )

    next Spotify::Client.get(
        path: "/v1/#{payload["res"]}/#{payload["id"]}",
        headers: HTTP::Headers{"Authorization" => "Bearer #{auth["access_token"].as_s}"}
    ).body
end

Kemal.config.port = 8080
Kemal.config.host_binding = "0.0.0.0"

Kemal.run