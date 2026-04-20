// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "firebase"

// 生成フォーム送信時にローディングオーバーレイを表示
const showLoadingOverlay = () => {
  const overlay = document.getElementById('loading-overlay')
  if (overlay) overlay.classList.remove('hidden')
}
const hideLoadingOverlay = () => {
  const overlay = document.getElementById('loading-overlay')
  if (overlay) overlay.classList.add('hidden')
}

const isGenerationForm = (form) => form && form.action && form.action.endsWith('/generations')

// Turbo経由（remote form）
document.addEventListener('turbo:submit-start', (event) => {
  if (isGenerationForm(event.target)) showLoadingOverlay()
})
document.addEventListener('turbo:submit-end', hideLoadingOverlay)
document.addEventListener('turbo:load', hideLoadingOverlay)

// 通常のsubmit（local: true や非Turboフォーム）
document.addEventListener('submit', (event) => {
  if (isGenerationForm(event.target)) showLoadingOverlay()
})

// ページ遷移完了時・bfcache復元時に非表示
window.addEventListener('pageshow', hideLoadingOverlay)

// セリフのコピーボタン
document.addEventListener('click', (e) => {
  const btn = e.target.closest('[data-serifu]')
  if (!btn) return

  navigator.clipboard.writeText(btn.dataset.serifu).then(() => {
    const original = btn.textContent
    btn.textContent = '✓ コピー済み'
    setTimeout(() => { btn.textContent = original }, 1500)
  })
})

// 入力文字数カウンタ（上限が近づくと色が変わる）
// Tailwindのarbitrary classはビルド時にスキャンされる必要があるため、
// 動的に切り替える色は style.color で直接指定する。
const COUNTER_COLORS = { normal: '#888888', warning: '#D4A017', danger: '#DC2626' }

const updateCounter = (input) => {
  const name = input.dataset.counterTarget
  const max = Number(input.dataset.counterMax)
  const label = document.querySelector(`[data-counter-for="${name}"]`)
  if (!label) return
  const current = input.value.length
  const currentEl = label.querySelector('[data-counter-current]')
  if (currentEl) currentEl.textContent = current
  const ratio = current / max
  if (ratio >= 1) {
    label.style.color = COUNTER_COLORS.danger
  } else if (ratio >= 0.8) {
    label.style.color = COUNTER_COLORS.warning
  } else {
    label.style.color = COUNTER_COLORS.normal
  }
}

document.addEventListener('turbo:load', () => {
  document.querySelectorAll('[data-counter-target]').forEach((input) => {
    updateCounter(input)
  })
})

document.addEventListener('input', (e) => {
  if (e.target.dataset && e.target.dataset.counterTarget) {
    updateCounter(e.target)
  }
})
