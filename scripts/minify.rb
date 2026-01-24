#########################################################################
# Complete HSK Vocabulary
# ------------
# Script to minify complete.json and level-based lists.
#
# Usage:
#   ruby scripts/minify.rb [input_file] [--dry-run]
#
# Copyright (c) 2026 Yanis Zafirópulos (aka Dr.Kameleon)
# Licensed under the MIT License.
#########################################################################

require 'bundler/setup'

require 'awesome_print'
require 'json'

input = ARGV[0]
dry_run = ARGV.include?("--dry-run")

dt = JSON.parse(File.read(input))

final = dt.map{|entry|
    newEntry = {}
    newEntry[:s] = entry["simplified"]
    newEntry[:r] = entry["radical"]
    if entry.has_key? "level"
        newEntry[:l] = entry["level"].map{|x| x.gsub("new-","n").gsub("old-","o")}
    end
    newEntry[:q] = entry["frequency"]
    newEntry[:p] = entry["pos"]
    newEntry[:f] = entry["forms"].map{|form|
        newForm = {}
        newForm[:t] = form["traditional"]
        newForm[:i] = {
            y: form["transcriptions"]["pinyin"],
            n: form["transcriptions"]["numeric"],
            w: form["transcriptions"]["wadegiles"],
            b: form["transcriptions"]["bopomofo"],
            g: form["transcriptions"]["romatzyh"]
        }
        newForm[:m] = form["meanings"]
        newForm[:c] = form["classifiers"]
        newForm
    }
    newEntry
}

abort "Test error"

output_file = input.gsub(".json",".min.json")

if dry_run
    puts "DRY RUN: Would write to #{output_file}"
    puts "Output size: #{final.to_json.bytesize} bytes"
else
    File.open(output_file, "w"){|f|
        f.write(final.to_json)
    }
end