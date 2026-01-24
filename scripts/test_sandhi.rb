# encoding: utf-8
#########################################################################
# Unit tests for the Sandhi module.
# Usage: ruby scripts/test_sandhi.rb
#########################################################################

require_relative 'sandhi'

class SandhiTest
  def initialize
    @passed = 0
    @failed = 0
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

  def run
    puts "=" * 60
    puts "Sandhi Module Unit Tests"
    puts "=" * 60

    testThirdToneSandhi
    testBuSandhi
    testYiSandhi
    testEdgeCases
    testAllTranscriptionSystems
    testApplyToEntry

    puts ""
    puts "=" * 60
    puts "Results: #{@passed} passed, #{@failed} failed"
    puts "=" * 60

    exit(@failed > 0 ? 1 : 0)
  end

  def testThirdToneSandhi
    puts "\n[Third Tone Sandhi]"

    assertEqual("ni2 hao3", Sandhi.apply_to_numeric("ni3 hao3"),
      "ni3 hao3 → ni2 hao3")

    assertEqual("ni2 hen2 hao3", Sandhi.apply_to_numeric("ni3 hen3 hao3"),
      "ni3 hen3 hao3 → ni2 hen2 hao3")

    assertEqual("ke2 yi3", Sandhi.apply_to_numeric("ke3 yi3"),
      "ke3 yi3 → ke2 yi3")

    assertEqual("xiao3 jie5", Sandhi.apply_to_numeric("xiao3 jie5"),
      "xiao3 jie5 → xiao3 jie5 (no change, neutral tone)")
  end

  def testBuSandhi
    puts "\n[不 Sandhi]"

    assertEqual("bu2 shi4", Sandhi.apply_to_numeric("bu4 shi4"),
      "bu4 shi4 → bu2 shi4")

    assertEqual("bu2 dui4", Sandhi.apply_to_numeric("bu4 dui4"),
      "bu4 dui4 → bu2 dui4")

    assertEqual("bu2 yao4", Sandhi.apply_to_numeric("bu4 yao4"),
      "bu4 yao4 → bu2 yao4")

    assertEqual("bu4 hao3", Sandhi.apply_to_numeric("bu4 hao3"),
      "bu4 hao3 → bu4 hao3 (no change, not before 4th)")

    assertEqual("bu4 neng2", Sandhi.apply_to_numeric("bu4 neng2"),
      "bu4 neng2 → bu4 neng2 (no change, not before 4th)")
  end

  def testYiSandhi
    puts "\n[一 Sandhi]"

    assertEqual("yi2 ge4", Sandhi.apply_to_numeric("yi1 ge4"),
      "yi1 ge4 → yi2 ge4")

    assertEqual("yi2 yang4", Sandhi.apply_to_numeric("yi1 yang4"),
      "yi1 yang4 → yi2 yang4")

    assertEqual("yi2 ding4", Sandhi.apply_to_numeric("yi1 ding4"),
      "yi1 ding4 → yi2 ding4")

    assertEqual("yi4 tian1", Sandhi.apply_to_numeric("yi1 tian1"),
      "yi1 tian1 → yi4 tian1")

    assertEqual("yi4 nian2", Sandhi.apply_to_numeric("yi1 nian2"),
      "yi1 nian2 → yi4 nian2")

    assertEqual("yi4 qi3", Sandhi.apply_to_numeric("yi1 qi3"),
      "yi1 qi3 → yi4 qi3")
  end

  def testEdgeCases
    puts "\n[Edge Cases]"

    assertEqual("hao3", Sandhi.apply_to_numeric("hao3"),
      "Single syllable unchanged")

    assertEqual("", Sandhi.apply_to_numeric(""),
      "Empty string unchanged")

    assertEqual(nil, Sandhi.apply_to_numeric(nil),
      "Nil unchanged")

    assertEqual("da4 jia1", Sandhi.apply_to_numeric("da4 jia1"),
      "da4 jia1 → da4 jia1 (no sandhi rules apply)")
  end

  def testAllTranscriptionSystems
    puts "\n[All Transcription Systems - 可以 ke3 yi3]"

    assertEqual("ké yǐ", Sandhi.apply_to_pinyin("kě yǐ"),
      "Pinyin: kě yǐ → ké yǐ")

    assertEqual("k'o² i³", Sandhi.apply_to_wadegiles("k'o³ i³"),
      "Wade-Giles: k'o³ i³ → k'o² i³")

    assertEqual("ㄎㄜˊ ㄧˇ", Sandhi.apply_to_bopomofo("ㄎㄜˇ ㄧˇ"),
      "Bopomofo: ㄎㄜˇ ㄧˇ → ㄎㄜˊ ㄧˇ")
  end

  def testApplyToEntry
    puts "\n[apply_to_entry]"

    entry = {
      "simplified" => "可以",
      "forms" => [{
        "transcriptions" => {
          "pinyin" => "kě yǐ",
          "numeric" => "ke3 yi3",
          "wadegiles" => "k'o³ i³",
          "bopomofo" => "ㄎㄜˇ ㄧˇ",
          "romatzyh" => "kee yii"
        }
      }]
    }

    result = Sandhi.apply_to_entry(entry)
    sandhiResult = result["forms"][0]["sandhi"]

    assertEqual("ké yǐ", sandhiResult["pinyin"],
      "Entry sandhi.pinyin correct")
    assertEqual("ke2 yi3", sandhiResult["numeric"],
      "Entry sandhi.numeric correct")
    assertEqual("k'o² i³", sandhiResult["wadegiles"],
      "Entry sandhi.wadegiles correct")
    assertEqual("ㄎㄜˊ ㄧˇ", sandhiResult["bopomofo"],
      "Entry sandhi.bopomofo correct")
    assertEqual("kee yii", sandhiResult["romatzyh"],
      "Entry sandhi.romatzyh unchanged (tones in spelling)")

    orig = result["forms"][0]["transcriptions"]
    assertEqual("kě yǐ", orig["pinyin"],
      "Original transcriptions preserved")
  end
end

SandhiTest.new.run
