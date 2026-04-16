# XSS 時の被害を抑える多層防御としての CSP。
# Firebase Auth + Google Identity Services + gstatic（FirebaseJS SDK配信）を壊さない範囲で絞る。

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri    :self
    policy.form_action :self
    policy.object_src  :none

    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.media_src   :self, :https, :data

    # スクリプトは HTTPS のみ。inline/eval は禁止
    policy.script_src  :self, :https

    # style は inline 属性（progress barの width 指定など）を許容
    policy.style_src   :self, :https, :unsafe_inline

    # Firebase / GIS の認証・トークンエンドポイント通信を許可（:https で十分）
    policy.connect_src :self, :https

    # Google 認証ポップアップ/iframe 用
    policy.frame_src   :self, :https
  end
end
