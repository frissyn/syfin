#!/usr/bin/env ruby

require 'uri'
require 'cli/ui'
require 'colorize'

require_relative 'syfin/actions'
require_relative 'syfin/parser'
require_relative 'syfin/requests'

module Syfin
    UI = CLI::UI
    VERSION = "0.0.1a".freeze
end

Syfin::UI::StdoutRouter.enable
Parser = Syfin::MainParser.new

# Split main operations into "pipelines"
# A pipline is defined as a script operation encased
# in an exception handler for expected or common errors.

# PARSING PIPLINE
# ---------------
begin
    args, opts = Parser.parse(ARGV, Syfin::VERSION).finalize()

    if opts[:is_uri]
        target = URI.parse(args[0]).path.split('/')
        args[0] = ["#{target[-2]}s", "#{target[-1]}"]
    else
        if /(tracks|playlists|albums):(.){22}/.match?(args[0])
            args[0] = args[0].split(":")
        else
            Syfin::UI.puts("✗ ParseError: Invalid Spotify ID.".red, to: $stderr)
            exit(1)
        end
    end

    if opts[:verbose]
        puts("✓ Parsed Options!".green)
    end
rescue OptionParser::ParseError => err
    Syfin::UI.puts("✗ ParseError: #{err.message}".red, to: $stderr)
    exit(1)
rescue URI::InvalidURIError => err
    Syfin::UI.puts("✗ InvalidURIError: #{err.message}".red, to: $stderr)
    exit(1)
end


# SPOTIFY PIPELINE
# ----------------
tries ||= 0
target = args[0][0][0..-2]
spins = Syfin::UI::SpinGroup.new

spins.add("Fetching #{target}...".red) do |spn|
    begin
        res = Syfin::Spotify.get(args[0][0], args[0][1])
        spn.update_title(
            "Found #{args[0][0][0..-2]} ".green +
            "\"#{res["name"]}\"! (Attempt #{tries + 1})".green
        )
    rescue
        if (tries += 1) < 3
            retry
        else
            spn.update_title("✗ #{err.message}".red, to: $stderr)
            exit(1)
        end
    end
end; spins.wait
