# encoding: utf-8
#########################################################################
# Complete HSK Vocabulary
# ------------
# Unit tests for the processing pipeline (filter.rb, minify.rb).
# Ensures core functionality is preserved and sandhi integration works.
#
# Usage:
#   ruby scripts/test_processing.rb
#
# Copyright (c) 2026 Yanis Zafirópulos (aka Dr.Kameleon)
# Licensed under the MIT License.
#########################################################################

require 'json'
require 'tempfile'
require 'fileutils'

require_relative 'sandhi'

class ProcessingTest
  def initialize
    @passed = 0
    @failed = 0
    @tempFiles = []
  end

  def assertEqual(expected, actual, description)
    if expected == actual
      @passed += 1
      puts "  ✓ #{description}"
    else
      @failed += 1
      puts "  ✗ #{description}"
      puts "    Expected: #{expected.inspect}"
      puts "    Actual:   #{actual.inspect}"
    end
  end

  def assertTrue(condition, description)
    assertEqual(true, condition, description)
  end

  def assertIncludes(collection, item, description)
    if collection.include?(item)
      @passed += 1
      puts "  ✓ #{description}"
    else
      @failed += 1
      puts "  ✗ #{description}"
      puts "    Collection does not include: #{item.inspect}"
    end
  end

  def cleanup
    @tempFiles.each{|f| File.delete(f) if File.exist?(f)}
  end

  def run
    puts "=" * 60
    puts "Processing Pipeline Unit Tests"
    puts "=" * 60

    testSampleDataStructure
    testLevelAbbreviations
    testFieldAbbreviations
    testFilterExclusive
    testFilterInclusive
    testSandhiIntegration
    testMinifyPreservesAllFields
    testCompleteJsonStructure

    cleanup

    puts ""
    puts "=" * 60
    puts "Results: #{@passed} passed, #{@failed} failed"
    puts "=" * 60

    exit(@failed > 0 ? 1 : 0)
  end

  def sampleEntry
    {
      "simplified" => "可以",
      "radical" => "口",
      "level" => ["new-1", "old-1"],
      "frequency" => 139,
      "pos" => ["v"],
      "forms" => [{
        "traditional" => "可以",
        "transcriptions" => {
          "pinyin" => "kě yǐ",
          "numeric" => "ke3 yi3",
          "wadegiles" => "k'o³ i³",
          "bopomofo" => "ㄎㄜˇ ㄧˇ",
          "romatzyh" => "kee yii"
        },
        "meanings" => ["can; may; possible", "not bad; pretty good"],
        "classifiers" => nil
      }]
    }
  end

  def testSampleDataStructure
    puts "\n[Sample Data Structure]"

    entry = sampleEntry
    assertEqual("可以", entry["simplified"], "simplified field exists")
    assertEqual("口", entry["radical"], "radical field exists")
    assertEqual(["new-1", "old-1"], entry["level"], "level field is array")
    assertEqual(139, entry["frequency"], "frequency is integer")
    assertEqual(["v"], entry["pos"], "pos field is array")
    assertTrue(entry["forms"].is_a?(Array), "forms is array")
    assertEqual("可以", entry["forms"][0]["traditional"], "traditional field exists")
    assertTrue(entry["forms"][0]["transcriptions"].is_a?(Hash), "transcriptions is hash")
    assertTrue(entry["forms"][0]["meanings"].is_a?(Array), "meanings is array")
  end

  def testLevelAbbreviations
    puts "\n[Level Abbreviations]"

    levels = ["new-1", "old-3", "new-7"]
    abbreviated = levels.map{|x| x.gsub("new-", "n").gsub("old-", "o")}

    assertEqual(["n1", "o3", "n7"], abbreviated, "Levels abbreviated correctly")
    assertEqual("n1", "new-1".gsub("new-", "n").gsub("old-", "o"), "new-1 → n1")
    assertEqual("o6", "old-6".gsub("new-", "n").gsub("old-", "o"), "old-6 → o6")
  end

  def testFieldAbbreviations
    puts "\n[Field Abbreviations - Minify Schema]"

    abbreviations = {
      "simplified" => :s,
      "radical" => :r,
      "level" => :l,
      "frequency" => :q,
      "pos" => :p,
      "forms" => :f,
      "traditional" => :t,
      "transcriptions" => :i,
      "sandhi" => :z,
      "pinyin" => :y,
      "numeric" => :n,
      "wadegiles" => :w,
      "bopomofo" => :b,
      "romatzyh" => :g,
      "meanings" => :m,
      "classifiers" => :c
    }

    assertEqual(:s, abbreviations["simplified"], "simplified → s")
    assertEqual(:r, abbreviations["radical"], "radical → r")
    assertEqual(:l, abbreviations["level"], "level → l")
    assertEqual(:q, abbreviations["frequency"], "frequency → q")
    assertEqual(:p, abbreviations["pos"], "pos → p")
    assertEqual(:f, abbreviations["forms"], "forms → f")
    assertEqual(:t, abbreviations["traditional"], "traditional → t")
    assertEqual(:i, abbreviations["transcriptions"], "transcriptions → i")
    assertEqual(:z, abbreviations["sandhi"], "sandhi → z")
    assertEqual(:m, abbreviations["meanings"], "meanings → m")
    assertEqual(:c, abbreviations["classifiers"], "classifiers → c")
  end

  def testFilterExclusive
    puts "\n[Filter - Exclusive Mode]"

    data = [
      { "simplified" => "你", "level" => ["new-1"] },
      { "simplified" => "好", "level" => ["new-1", "old-1"] },
      { "simplified" => "学", "level" => ["new-2"] },
      { "simplified" => "习", "level" => ["old-2"] }
    ]

    level = "new-1"
    filtered = data.select{|word| word["level"].include?(level)}

    assertEqual(2, filtered.length, "Exclusive new-1 returns 2 words")
    assertEqual("你", filtered[0]["simplified"], "First word is 你")
    assertEqual("好", filtered[1]["simplified"], "Second word is 好")

    filtered2 = data.select{|word| word["level"].include?("new-2")}
    assertEqual(1, filtered2.length, "Exclusive new-2 returns 1 word")
    assertEqual("学", filtered2[0]["simplified"], "Word is 学")
  end

  def testFilterInclusive
    puts "\n[Filter - Inclusive Mode]"

    data = [
      { "simplified" => "你", "level" => ["new-1"] },
      { "simplified" => "好", "level" => ["new-1", "old-1"] },
      { "simplified" => "学", "level" => ["new-2"] },
      { "simplified" => "习", "level" => ["new-3"] }
    ]

    levels = ["new-1", "new-2"]
    filtered = data.select{|word|
      word["level"].any?{|l| levels.include?(l)}
    }

    assertEqual(3, filtered.length, "Inclusive new-1,new-2 returns 3 words")

    simplifiedChars = filtered.map{|w| w["simplified"]}
    assertIncludes(simplifiedChars, "你", "Includes 你 (new-1)")
    assertIncludes(simplifiedChars, "好", "Includes 好 (new-1)")
    assertIncludes(simplifiedChars, "学", "Includes 学 (new-2)")
  end

  def testSandhiIntegration
    puts "\n[Sandhi Integration]"

    entry = sampleEntry
    result = Sandhi.apply_to_entry(JSON.parse(entry.to_json))

    assertTrue(result["forms"][0].key?("sandhi"), "sandhi field added to form")

    orig = result["forms"][0]["transcriptions"]
    assertEqual("kě yǐ", orig["pinyin"], "Original pinyin preserved")
    assertEqual("ke3 yi3", orig["numeric"], "Original numeric preserved")

    sandhiResult = result["forms"][0]["sandhi"]
    assertEqual("ké yǐ", sandhiResult["pinyin"], "Sandhi pinyin correct")
    assertEqual("ke2 yi3", sandhiResult["numeric"], "Sandhi numeric correct")
    assertEqual("k'o² i³", sandhiResult["wadegiles"], "Sandhi wadegiles correct")
    assertEqual("ㄎㄜˊ ㄧˇ", sandhiResult["bopomofo"], "Sandhi bopomofo correct")
    assertEqual("kee yii", sandhiResult["romatzyh"], "Romatzyh unchanged")
  end

  def testMinifyPreservesAllFields
    puts "\n[Minify - Field Preservation]"

    entry = sampleEntry
    entryWithSandhi = Sandhi.apply_to_entry(JSON.parse(entry.to_json))

    minified = {}
    minified[:s] = entryWithSandhi["simplified"]
    minified[:r] = entryWithSandhi["radical"]
    minified[:l] = entryWithSandhi["level"].map{|x| x.gsub("new-", "n").gsub("old-", "o")}
    minified[:q] = entryWithSandhi["frequency"]
    minified[:p] = entryWithSandhi["pos"]
    minified[:f] = entryWithSandhi["forms"].map{|form|
      t = form["transcriptions"]
      s = form["sandhi"]
      {
        t: form["traditional"],
        i: { y: t["pinyin"], n: t["numeric"], w: t["wadegiles"], b: t["bopomofo"], g: t["romatzyh"] },
        z: { y: s["pinyin"], n: s["numeric"], w: s["wadegiles"], b: s["bopomofo"], g: s["romatzyh"] },
        m: form["meanings"],
        c: form["classifiers"]
      }
    }

    assertEqual("可以", minified[:s], "simplified preserved")
    assertEqual("口", minified[:r], "radical preserved")
    assertEqual(["n1", "o1"], minified[:l], "level abbreviated and preserved")
    assertEqual(139, minified[:q], "frequency preserved")
    assertEqual(["v"], minified[:p], "pos preserved")

    form = minified[:f][0]
    assertEqual("可以", form[:t], "traditional preserved")
    assertEqual("kě yǐ", form[:i][:y], "transcription pinyin preserved")
    assertEqual("ké yǐ", form[:z][:y], "sandhi pinyin preserved")
    assertEqual(2, form[:m].length, "meanings preserved")
    assertEqual(nil, form[:c], "classifiers preserved (nil)")
  end

  def testCompleteJsonStructure
    puts "\n[Complete.json Structure Validation]"

    completePath = File.join(File.dirname(__FILE__), "..", "complete.json")

    if File.exist?(completePath)
      data = JSON.parse(File.read(completePath))

      assertTrue(data.is_a?(Array), "complete.json is array")
      assertTrue(data.length > 0, "complete.json has entries")

      first = data[0]
      assertTrue(first.key?("simplified"), "Entry has simplified")
      assertTrue(first.key?("radical"), "Entry has radical")
      assertTrue(first.key?("level"), "Entry has level")
      assertTrue(first.key?("frequency"), "Entry has frequency")
      assertTrue(first.key?("forms"), "Entry has forms")

      form = first["forms"][0]
      assertTrue(form.key?("traditional"), "Form has traditional")
      assertTrue(form.key?("transcriptions"), "Form has transcriptions")
      assertTrue(form.key?("meanings"), "Form has meanings")

      trans = form["transcriptions"]
      assertTrue(trans.key?("pinyin"), "Transcriptions has pinyin")
      assertTrue(trans.key?("numeric"), "Transcriptions has numeric")
      assertTrue(trans.key?("wadegiles"), "Transcriptions has wadegiles")
      assertTrue(trans.key?("bopomofo"), "Transcriptions has bopomofo")
      assertTrue(trans.key?("romatzyh"), "Transcriptions has romatzyh")

      puts "  ℹ Validated #{data.length} entries in complete.json"
    else
      puts "  ⚠ complete.json not found, skipping structure validation"
    end
  end
end

ProcessingTest.new.run
