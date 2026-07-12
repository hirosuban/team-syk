# 会話劇（キャラ画像つき吹き出し）用のカスタムブロック //talk
#
# 使い方:
#   //talk[yuragi]{
#   IDがあるなら、その人を特定できますよね？
#   //}
#
# 話者を追加したいときは TALK_SPEAKERS にエントリを足す。
# side: 'left'  → 左にアイコン・右に吹き出し
# side: 'right' → 右にアイコン・左に吹き出し
module ReVIEW
  TALK_SPEAKERS = {
    'yuragi' => { name: '揺 百々', image: 'images/yuragimomo.png', side: 'left' },
    'nayose' => { name: '名寄 一', image: 'images/nayosehajime.png', side: 'right' },
  }.freeze

  def self.talk_speaker(id)
    TALK_SPEAKERS[id] or raise "//talk: 未定義の話者です: #{id}（review-ext.rb の TALK_SPEAKERS に追加してください）"
  end

  Compiler.defblock :talk, 1

  class LATEXBuilder
    def talk(lines, speaker)
      s = ReVIEW.talk_speaker(speaker)
      macro = s[:side] == 'right' ? 'reviewtalkright' : 'reviewtalkleft'
      puts "\\#{macro}{#{s[:image]}}{#{s[:name]}}{%"
      puts lines.join("\n")
      puts '}'
    end
  end

  class HTMLBuilder
    def talk(lines, speaker)
      s = ReVIEW.talk_speaker(speaker)
      puts %Q(<div class="talk talk-#{s[:side]}">)
      puts %Q(<div class="talk-icon"><img src="#{s[:image]}" alt="#{s[:name]}" /><span class="talk-name">#{s[:name]}</span></div>)
      puts %Q(<div class="talk-bubble"><p>#{lines.join}</p></div>)
      puts '</div>'
    end
  end

  # text / markdown ビルド用のフォールバック（定義されているビルダーだけに生やす）
  %i[TOPBuilder PLAINTEXTBuilder MARKDOWNBuilder].each do |klass|
    next unless ReVIEW.const_defined?(klass)

    ReVIEW.const_get(klass).class_eval do
      def talk(lines, speaker)
        s = ReVIEW.talk_speaker(speaker)
        puts "#{s[:name]}「#{lines.join}」"
        puts ''
      end
    end
  end
end
