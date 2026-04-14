class Genre
  LIST = [
    { slug: 'romance',  name: '恋愛・甘々',   emoji: '💕' },
    { slug: 'tsundere', name: 'ツンデレ',     emoji: '😤' },
    { slug: 'fantasy',  name: 'ファンタジー', emoji: '🧙' },
    { slug: 'daily',    name: '日常・癒し',   emoji: '☀️' },
    { slug: 'comedy',   name: 'コメディ',     emoji: '😂' },
    { slug: 'random',   name: 'おまかせ',     emoji: '🎲' }
  ].freeze

  def self.all
    LIST
  end

  def self.find(slug)
    LIST.find { |g| g[:slug] == slug }
  end
end
