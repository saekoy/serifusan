class SessionsController < ApplicationController
  # JSからの fetch POST は CSRF 対応のため authenticity_token ヘッダーを付けてもらう
  # （application.html.erb の csrf-token から取り出して送る。JS側で実装済み予定）

  # POST /sessions
  # ブラウザから Firebase の IDトークンを受け取り、検証→User作成→session確立
  def create
    id_token = params[:id_token]
    return head(:bad_request) if id_token.blank?

    payload = FirebaseTokenVerifier.verify(id_token)

    user = User.find_or_initialize_by(firebase_uid: payload[:uid])
    user.assign_attributes(
      email:        payload[:email],
      display_name: payload[:display_name],
      photo_url:    payload[:photo_url],
      provider:     payload[:provider]
    )
    user.save!

    session[:user_id] = user.id
    head :ok
  rescue FirebaseTokenVerifier::VerificationError => e
    Rails.logger.warn("Firebase token verification failed: #{e.message}")
    head :unauthorized
  end

  # DELETE /sessions
  def destroy
    session.delete(:user_id)
    head :ok
  end
end
