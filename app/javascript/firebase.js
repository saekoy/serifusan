import { initializeApp } from "firebase/app"
import { getAuth, GoogleAuthProvider, signInWithCredential, onAuthStateChanged, signOut } from "firebase/auth"

// Firebase コンソールで取得した設定値（apiKey は公開前提の識別子のため直書きOK）
const firebaseConfig = {
  apiKey: "AIzaSyCbC5JiEl72p7f49EVYzHoe5snF3wIuGJA",
  authDomain: "serifusan-237f2.firebaseapp.com",
  projectId: "serifusan-237f2",
  storageBucket: "serifusan-237f2.firebasestorage.app",
  messagingSenderId: "915693857966",
  appId: "1:915693857966:web:e285fb42211cc778f5513f",
  measurementId: "G-NFLZSP7SEJ"
}

// Google Identity Services 用の Web クライアントID（公開前提）
const GOOGLE_CLIENT_ID = "915693857966-t70f1qtdivb5btgek601m2fep51vjmqt.apps.googleusercontent.com"

const app = initializeApp(firebaseConfig)
export const auth = getAuth(app)

// 動作確認用（あとで消してOK）
window.firebaseApp = app
window.firebaseAuth = auth
console.log("[firebase] initialized:", app.name)

// 認証状態の変化を監視：ログイン成功時に Rails にIDトークンを送信
// サーバー側が既にログイン状態ならPOSTしない（無限リロード防止）
let railsSessionEstablished = document.querySelector('meta[name="logged-in"]')?.content === "true"

onAuthStateChanged(auth, async (user) => {
  if (user) {
    const idToken = await user.getIdToken()
    console.log("[firebase] logged in:", user.displayName, user.email)
    if (!railsSessionEstablished) {
      await establishRailsSession(idToken)
    }
  } else {
    console.log("[firebase] logged out")
    railsSessionEstablished = false
  }
})

// IDトークンを Rails にPOSTしてセッション確立
async function establishRailsSession(idToken) {
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
  try {
    const response = await fetch("/sessions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken || "",
        "Accept": "application/json"
      },
      body: JSON.stringify({ id_token: idToken })
    })
    if (response.ok) {
      railsSessionEstablished = true
      console.log("[rails] session established, reloading...")
      window.location.reload()
    } else {
      console.error("[rails] session failed:", response.status)
    }
  } catch (error) {
    console.error("[rails] session fetch error:", error)
  }
}

// ===== ログアウト：Firebase と Rails の両方からログアウト =====
// Firebase だけログアウトすると Rails セッションが残る
// Rails だけログアウトすると onAuthStateChanged が再発火してまた /sessions POST → 無限ループ
window.signOutCompletely = async () => {
  try {
    await signOut(auth)
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
    await fetch("/sessions", {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": csrfToken || "",
        "Accept": "application/json"
      }
    })
    window.location.href = "/"
  } catch (error) {
    console.error("[logout] error:", error)
  }
}

// ===== GIS から受け取った credential を Firebase に渡す =====
async function handleCredential(response) {
  try {
    const credential = GoogleAuthProvider.credential(response.credential)
    const result = await signInWithCredential(auth, credential)
    console.log("[firebase] signInWithCredential success:", result.user.email)
  } catch (error) {
    console.error("[firebase] signInWithCredential error:", error.code, error.message)
  }
}

// ===== GIS 初期化 + ボタン描画 =====
let gisInitialized = false

function setupGIS() {
  if (!window.google?.accounts?.id) return // GIS スクリプト未ロード

  if (!gisInitialized) {
    google.accounts.id.initialize({
      client_id: GOOGLE_CLIENT_ID,
      callback: handleCredential,
    })
    gisInitialized = true
    console.log("[GIS] initialized")
  }
  renderButtons()
}

function renderButtons() {
  document.querySelectorAll("[data-gis-button]").forEach((el) => {
    el.innerHTML = ""
    google.accounts.id.renderButton(el, {
      theme: "filled_blue",
      size: "large",
      text: "signin_with",
      shape: "rectangular",
      logo_alignment: "center",
    })
  })
}

// GIS スクリプトがロードされたときに呼ばれるグローバルコールバック
window.onGoogleLibraryLoad = setupGIS

// Turbo ナビゲーション時にもボタンを再描画
document.addEventListener("turbo:load", setupGIS)
document.addEventListener("DOMContentLoaded", setupGIS)
