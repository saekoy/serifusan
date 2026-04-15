# Firebase Auth の signInWithPopup がポップアップ閉じ検知で window.closed を呼ぶが、
# Rails 8 デフォルトの COOP: same-origin だとブロックされるため緩める。
# same-origin-allow-popups は同一オリジンの分離を保ったままポップアップ通信のみ許可する。
Rails.application.config.action_dispatch.default_headers.merge!(
  "Cross-Origin-Opener-Policy" => "same-origin-allow-popups"
)
