#########################################################################
# Complete HSK Vocabulary
# ------------
# Script to filter complete.json 
# into level-based lists, either exclusive or inclusive.
#
# Usage:
#   ruby scripts/filter.rb [exclusive|inclusive] 
#                          [level1] [level2] ... [--dry-run]
#
# Copyright (c) 2026 Yanis Zafirópulos (aka Dr.Kameleon)
# Licensed under the MIT License.
#########################################################################

require 'bundler/setup'

require 'json'
require 'neatjson'
require 'fileutils'

script_dir = __dir__
root_dir = File.expand_path("..", script_dir)

data = JSON.parse(File.read("#{root_dir}/complete.json"))

dry_run = ARGV.include?("--dry-run")
args = ARGV.reject { |arg| arg == "--dry-run" }

mode = args[0]
levels = args[1..-1]

if mode != "exclusive" && mode != "inclusive"
  puts "Usage: ruby filter.rb [exclusive|inclusive] [level1] [level2] ... [--dry-run]"
  exit 1
end

final = []
data.each{|word|
    if mode == "exclusive"
        # exclusive mode: check if word level includes the single level
        if word["level"].include?(levels[0])
            copied = JSON.parse(word.to_json)  # deep copy
            copied.delete("level")
            final << copied
        end
    else
        # inclusive mode: check if word level includes ANY of the levels
        anyLevel = false
        wordLevel = word["level"]
        levels.each{|what|
            if wordLevel.include?(what)
                anyLevel = true
            end
        }
        if anyLevel
            copied = JSON.parse(word.to_json)  # deep copy
            copied.delete("level")
            final << copied
        end
    end
}

finalDir = "new"
if levels.first.include?("old")
    finalDir = "old"
end

clean = levels.last.gsub("old-","").gsub("new-","")

opts = { short:true, aligned:true,
         padding:1, after_comma:1, around_colon_n:1 }

neat = JSON.neat_generate( final, opts )

targetPath = "#{root_dir}/wordlists/#{mode}/#{finalDir}"
output_file = "#{targetPath}/#{clean}.json"

if dry_run
    puts "DRY RUN: Would write to #{output_file}"
    puts "Words filtered: #{final.count}"
    puts "Output size: #{neat.bytesize} bytes"
else
    FileUtils.mkdir_p(targetPath) unless Dir.exist?(targetPath)
    File.open(output_file,"w"){|f|
        f.write(neat)
    }
end