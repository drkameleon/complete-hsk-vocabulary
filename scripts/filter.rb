require 'json'
require 'neatjson'
require 'fileutils'

script_dir = __dir__
root_dir = File.expand_path("..", script_dir)

data = JSON.parse(File.read("#{root_dir}/complete.json"))

mode = ARGV[0]
levels = ARGV[1..-1]

if mode != "exclusive" && mode != "inclusive"
  puts "Usage: ruby filter.rb [exclusive|inclusive] [level1] [level2] ..."
  exit 1
end

final = []
data.each{|word|
    if mode == "exclusive"
        # exclusive mode: check if word level includes the single level
        if word["level"].include?(levels[0])
            copied = word
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
            copied = word
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
FileUtils.mkdir_p(targetPath) unless Dir.exist?(targetPath)

File.open("#{targetPath}/#{clean}.json","w"){|f|
    f.write(neat)
}