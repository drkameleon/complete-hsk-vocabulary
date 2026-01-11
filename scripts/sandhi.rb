# encoding: utf-8
#########################################################################
# Sandhi Module
#
# Applies Mandarin tone sandhi rules to all transcription systems.
#
# Rules implemented:
#   1. Third tone sandhi: 3 → 2 before another 3rd tone
#   2. 不 (bu4) sandhi: bu4 → bu2 before 4th tone
#   3. 一 (yi1) sandhi: yi1 → yi4 before 1st/2nd/3rd, yi1 → yi2 before 4th
#
# Supported transcription systems:
#   - pinyin (tone marks: ā á ǎ à)
#   - numeric (tone numbers: 1 2 3 4 5)
#   - wadegiles (superscript numbers: ¹ ² ³ ⁴ ⁵)
#   - bopomofo (tone marks: ˊ ˇ ˋ ˙)
#   - romatzyh (tones encoded in spelling - not modified due to complexity)
#########################################################################

module Sandhi
  # Pinyin tone mark mappings for each vowel
  TONE_MARKS = {
    'a' => ['ā', 'á', 'ǎ', 'à'],
    'e' => ['ē', 'é', 'ě', 'è'],
    'i' => ['ī', 'í', 'ǐ', 'ì'],
    'o' => ['ō', 'ó', 'ǒ', 'ò'],
    'u' => ['ū', 'ú', 'ǔ', 'ù'],
    'ü' => ['ǖ', 'ǘ', 'ǚ', 'ǜ']
  }

  # Reverse mapping: marked vowel → [base vowel, tone number]
  MARK_TO_TONE = {}
  TONE_MARKS.each do |base, marks|
    marks.each_with_index do |mark, idx|
      MARK_TO_TONE[mark] = [base, idx + 1]
    end
  end

  # Wade-Giles superscript numbers
  WADEGILES_TONES = ['¹', '²', '³', '⁴', '⁵']
  WADEGILES_TO_NUM = { '¹' => 1, '²' => 2, '³' => 3, '⁴' => 4, '⁵' => 5 }

  # Bopomofo tone marks (tone 1 has no mark, placed after; neutral tone ˙ placed before)
  # ˊ = tone 2, ˇ = tone 3, ˋ = tone 4
  BOPOMOFO_MARKS = { 2 => 'ˊ', 3 => 'ˇ', 4 => 'ˋ' }
  BOPOMOFO_TO_TONE = { 'ˊ' => 2, 'ˇ' => 3, 'ˋ' => 4 }

  #---------------------------------------------------------------------------
  # Core sandhi logic - returns array of [original_tone, new_tone] pairs
  #---------------------------------------------------------------------------
  def self.compute_tone_changes(tones)
    return [] if tones.length < 2

    changes = Array.new(tones.length) { |i| [tones[i], tones[i]] }
    original_tones = tones.dup

    (0...(tones.length - 1)).reverse_each do |i|
      current_tone = original_tones[i]
      next_original_tone = original_tones[i + 1]
      next_new_tone = changes[i + 1][1]

      new_tone = current_tone

      # Rule 1: Third tone sandhi (3 → 2 before 3)
      if current_tone == 3 && next_original_tone == 3
        new_tone = 2
      end

      # Rule 2: 不 sandhi - handled separately per transcription system

      # Rule 3: 一 sandhi - handled separately per transcription system

      changes[i] = [current_tone, new_tone]
    end

    changes
  end

  #---------------------------------------------------------------------------
  # Numeric pinyin (e.g., "ni3 hao3" → "ni2 hao3")
  #---------------------------------------------------------------------------
  def self.apply_to_numeric(numeric)
    return numeric if numeric.nil? || numeric.empty?

    syllables = numeric.split(' ')
    return numeric if syllables.length < 2

    original_tones = syllables.map { |s| s[-1].to_i }
    new_tones = original_tones.dup

    (0...(syllables.length - 1)).reverse_each do |i|
      current = syllables[i]
      current_tone = original_tones[i]
      current_base = current[0...-1]
      next_original_tone = original_tones[i + 1]
      next_tone = new_tones[i + 1]

      # Rule 1: Third tone sandhi
      if current_tone == 3 && next_original_tone == 3
        syllables[i] = "#{current_base}2"
        new_tones[i] = 2
      end

      # Rule 2: 不 sandhi
      if current_base.downcase == 'bu' && current_tone == 4 && next_tone == 4
        syllables[i] = "#{current_base}2"
        new_tones[i] = 2
      end

      # Rule 3: 一 sandhi
      if current_base.downcase == 'yi' && current_tone == 1
        if next_tone == 4
          syllables[i] = "#{current_base}2"
          new_tones[i] = 2
        elsif [1, 2, 3].include?(next_tone)
          syllables[i] = "#{current_base}4"
          new_tones[i] = 4
        end
      end
    end

    syllables.join(' ')
  end

  #---------------------------------------------------------------------------
  # Tone-marked pinyin (e.g., "nǐ hǎo" → "ní hǎo")
  #---------------------------------------------------------------------------
  def self.apply_to_pinyin(pinyin)
    return pinyin if pinyin.nil? || pinyin.empty?

    syllables = pinyin.split(' ')
    return pinyin if syllables.length < 2

    numeric_syllables = syllables.map { |s| marked_to_numeric(s) }
    original_tones = numeric_syllables.map { |s| extract_tone(s) }
    new_tones = original_tones.dup

    (0...(syllables.length - 1)).reverse_each do |i|
      current_numeric = numeric_syllables[i]
      current_tone = original_tones[i]
      current_base = current_numeric[0...-1]
      next_original_tone = original_tones[i + 1]
      next_tone = new_tones[i + 1]
      result_tone = current_tone

      # Rule 1: Third tone sandhi
      if current_tone == 3 && next_original_tone == 3
        result_tone = 2
      end

      # Rule 2: 不 sandhi
      if current_base.downcase == 'bu' && current_tone == 4 && next_tone == 4
        result_tone = 2
      end

      # Rule 3: 一 sandhi
      if current_base.downcase == 'yi' && current_tone == 1
        if next_tone == 4
          result_tone = 2
        elsif [1, 2, 3].include?(next_tone)
          result_tone = 4
        end
      end

      if result_tone != current_tone
        syllables[i] = change_tone_mark(syllables[i], result_tone)
        new_tones[i] = result_tone
      end
    end

    syllables.join(' ')
  end

  #---------------------------------------------------------------------------
  # Wade-Giles (e.g., "ai⁴ hao⁴" → "ai² hao⁴")
  #---------------------------------------------------------------------------
  def self.apply_to_wadegiles(wadegiles)
    return wadegiles if wadegiles.nil? || wadegiles.empty?

    syllables = wadegiles.split(' ')
    return wadegiles if syllables.length < 2

    # Extract tones from superscript numbers
    original_tones = syllables.map { |s| extract_wadegiles_tone(s) }
    new_tones = original_tones.dup

    (0...(syllables.length - 1)).reverse_each do |i|
      current = syllables[i]
      current_tone = original_tones[i]
      current_base = strip_wadegiles_tone(current)
      next_original_tone = original_tones[i + 1]
      next_tone = new_tones[i + 1]
      result_tone = current_tone

      # Rule 1: Third tone sandhi
      if current_tone == 3 && next_original_tone == 3
        result_tone = 2
      end

      # Rule 2: 不 sandhi (bu in Wade-Giles is "pu")
      if current_base.downcase == 'pu' && current_tone == 4 && next_tone == 4
        result_tone = 2
      end

      # Rule 3: 一 sandhi (yi in Wade-Giles is "i" or "yi")
      if (current_base.downcase == 'i' || current_base.downcase == 'yi') && current_tone == 1
        if next_tone == 4
          result_tone = 2
        elsif [1, 2, 3].include?(next_tone)
          result_tone = 4
        end
      end

      if result_tone != current_tone
        syllables[i] = "#{current_base}#{WADEGILES_TONES[result_tone - 1]}"
        new_tones[i] = result_tone
      end
    end

    syllables.join(' ')
  end

  def self.extract_wadegiles_tone(syllable)
    WADEGILES_TONES.each_with_index do |mark, idx|
      return idx + 1 if syllable.include?(mark)
    end
    5 # neutral tone
  end

  def self.strip_wadegiles_tone(syllable)
    result = syllable.dup
    WADEGILES_TONES.each { |mark| result = result.gsub(mark, '') }
    result
  end

  #---------------------------------------------------------------------------
  # Bopomofo (e.g., "ㄋㄧˇ ㄏㄠˇ" → "ㄋㄧˊ ㄏㄠˇ")
  # Tone marks: (none)=1, ˊ=2, ˇ=3, ˋ=4, ˙=5 (neutral, placed before)
  #---------------------------------------------------------------------------
  def self.apply_to_bopomofo(bopomofo)
    return bopomofo if bopomofo.nil? || bopomofo.empty?

    syllables = bopomofo.split(' ')
    return bopomofo if syllables.length < 2

    original_tones = syllables.map { |s| extract_bopomofo_tone(s) }
    new_tones = original_tones.dup

    (0...(syllables.length - 1)).reverse_each do |i|
      current = syllables[i]
      current_tone = original_tones[i]
      current_base = strip_bopomofo_tone(current)
      next_original_tone = original_tones[i + 1]
      next_tone = new_tones[i + 1]
      result_tone = current_tone

      # Rule 1: Third tone sandhi
      if current_tone == 3 && next_original_tone == 3
        result_tone = 2
      end

      # Rule 2: 不 sandhi (不 in bopomofo is ㄅㄨ)
      if current_base == 'ㄅㄨ' && current_tone == 4 && next_tone == 4
        result_tone = 2
      end

      # Rule 3: 一 sandhi (一 in bopomofo is ㄧ)
      if current_base == 'ㄧ' && current_tone == 1
        if next_tone == 4
          result_tone = 2
        elsif [1, 2, 3].include?(next_tone)
          result_tone = 4
        end
      end

      if result_tone != current_tone
        syllables[i] = apply_bopomofo_tone(current_base, result_tone)
        new_tones[i] = result_tone
      end
    end

    syllables.join(' ')
  end

  def self.extract_bopomofo_tone(syllable)
    return 5 if syllable.start_with?('˙')  # neutral tone marker before
    BOPOMOFO_TO_TONE.each do |mark, tone|
      return tone if syllable.include?(mark)
    end
    1 # no mark = first tone
  end

  def self.strip_bopomofo_tone(syllable)
    result = syllable.dup
    result = result[1..-1] if result.start_with?('˙')
    BOPOMOFO_TO_TONE.keys.each { |mark| result = result.gsub(mark, '') }
    result
  end

  def self.apply_bopomofo_tone(base, tone)
    case tone
    when 1 then base  # no mark
    when 2, 3, 4 then "#{base}#{BOPOMOFO_MARKS[tone]}"
    when 5 then "˙#{base}"  # neutral tone before
    else base
    end
  end

  #---------------------------------------------------------------------------
  # Helper methods for pinyin
  #---------------------------------------------------------------------------
  def self.marked_to_numeric(syllable)
    base = syllable.dup
    tone = 5

    MARK_TO_TONE.each do |mark, (vowel, t)|
      if base.include?(mark)
        base = base.gsub(mark, vowel)
        tone = t
        break
      end
    end

    "#{base}#{tone}"
  end

  def self.extract_tone(numeric_syllable)
    return 5 if numeric_syllable.nil? || numeric_syllable.empty?
    last_char = numeric_syllable[-1]
    last_char.match?(/[1-5]/) ? last_char.to_i : 5
  end

  def self.change_tone_mark(syllable, new_tone)
    return syllable if new_tone == 5 || new_tone < 1 || new_tone > 4

    MARK_TO_TONE.each do |mark, (base_vowel, _old_tone)|
      if syllable.include?(mark)
        new_mark = TONE_MARKS[base_vowel][new_tone - 1]
        return syllable.gsub(mark, new_mark)
      end
    end

    syllable
  end

  #---------------------------------------------------------------------------
  # Apply sandhi to entry - adds new "sandhi" field, keeps originals intact
  #---------------------------------------------------------------------------
  def self.apply_to_entry(entry)
    return entry unless entry["forms"]

    entry["forms"].each do |form|
      next unless form["transcriptions"]

      t = form["transcriptions"]

      # Create sandhi versions of all applicable transcriptions
      sandhi = {}
      sandhi["pinyin"] = apply_to_pinyin(t["pinyin"]) if t["pinyin"]
      sandhi["numeric"] = apply_to_numeric(t["numeric"]) if t["numeric"]
      sandhi["wadegiles"] = apply_to_wadegiles(t["wadegiles"]) if t["wadegiles"]
      sandhi["bopomofo"] = apply_to_bopomofo(t["bopomofo"]) if t["bopomofo"]
      # Romatzyh (Gwoyeu Romatzyh) encodes tones in spelling - too complex to modify algorithmically
      # We include it unchanged for completeness
      sandhi["romatzyh"] = t["romatzyh"] if t["romatzyh"]

      form["sandhi"] = sandhi
    end

    entry
  end

  # Apply sandhi to all entries in a dataset
  def self.apply_to_dataset(data)
    data.map { |entry| apply_to_entry(entry.dup) }
  end
end

#---------------------------------------------------------------------------
# Standalone script mode - applies sandhi to complete.json
# Usage: ruby scripts/sandhi.rb [--dry-run]
#---------------------------------------------------------------------------
if __FILE__ == $0
  require 'json'
  require 'neatjson'

  scriptDir = __dir__
  rootDir = File.expand_path("..", scriptDir)

  dryRun = ARGV.include?("--dry-run")

  inputFile = "#{rootDir}/complete.json"
  data = JSON.parse(File.read(inputFile))

  data.each{|entry|
    Sandhi.apply_to_entry(entry)
  }

  opts = { short:true, aligned:true,
           padding:1, after_comma:1, around_colon_n:1 }

  output = JSON.neat_generate(data, opts)

  if dryRun
    puts "DRY RUN: Would update #{inputFile}"
    puts "Entries processed: #{data.length}"
    puts "Output size: #{output.bytesize} bytes"

    sample = data.find{|e| e["simplified"] == "可以"} || data[0]
    if sample && sample["forms"][0]["sandhi"]
      puts "\nSample sandhi field added:"
      puts "  transcriptions.numeric: #{sample["forms"][0]["transcriptions"]["numeric"]}"
      puts "  sandhi.numeric: #{sample["forms"][0]["sandhi"]["numeric"]}"
    end
  else
    File.open(inputFile, "w"){|f|
      f.write(output)
    }
  end
end
