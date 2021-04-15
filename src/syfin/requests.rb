require 'json'
require 'httparty'

module Syfin
    class Spotify
        @@BASE = "https://syfin-api.frissyn.repl.co"

        def Spotify.get(type, data)
            res = HTTParty.get("#{@@BASE}/s/#{type}/#{data}")

            return JSON.parse(res.body)
        end
    end
end
