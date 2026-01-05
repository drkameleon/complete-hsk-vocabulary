require 'awesome_print'
require 'json'

input = ARGV[0]

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

File.open(input.gsub(".json",".min.json"), "w"){|f|
    f.write(final.to_json)
}
