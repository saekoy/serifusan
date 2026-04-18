require 'net/http'

class GeminiService
  API_URL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent'.freeze
  COUNT = 10

  def initialize(genre:, theme:, first_person: nil, tone: nil, character: nil)
    @genre        = genre
    @theme        = theme
    @first_person = first_person
    @tone         = tone
    @character    = character
  end

  def call
    response = request_to_gemini(build_prompt)
    parse_serifus(response)
  end

  private

  def build_prompt
    genre_name = Genre.find(@genre)&.dig(:name) || @genre
    lines = [
      'あなたはVライバー向けのセリフ生成AIです。',
      "以下の条件に合ったセリフを#{COUNT}個生成してください。",
      '',
      "【ジャンル】#{genre_name}"
    ]
    lines << "【テーマ】#{@theme}" if @theme.present?
    lines << "【一人称】#{@first_person}" if @first_person.present?
    lines << "【口調】#{@tone}" if @tone.present? && @tone != '指定なし'
    lines << "【キャラ設定】#{@character}" if @character.present?
    lines << ''
    lines << '出力：セリフのみのJSON配列。説明不要。各100〜140文字程度の自然な日本語で、Vライバーが配信中に話すセリフとして自然な長さにしてください。'
    lines << '例：["セリフ1","セリフ2"]'
    lines.join("\n")
  end

  def request_to_gemini(prompt)
    uri  = URI(API_URL)
    body = {
      contents: [{
        parts: [{ text: prompt }]
      }]
    }.to_json

    http         = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request      = Net::HTTP::Post.new(uri)
    request['Content-Type']   = 'application/json'
    request['x-goog-api-key'] = ENV.fetch('GEMINI_API_KEY', nil)
    request.body = body

    http.request(request)
  end

  def parse_serifus(response)
    body      = JSON.parse(response.body)
    text      = body.dig('candidates', 0, 'content', 'parts', 0, 'text')
    json_text = text&.match(/\[.*\]/m)&.to_s
    JSON.parse(json_text || '[]').first(COUNT)
  rescue StandardError => e
    Rails.logger.error "GeminiService error: #{e.message}"
    []
  end
end
