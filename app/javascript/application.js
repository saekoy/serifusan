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
const updateCounter = (input) => {
  const name = input.dataset.counterTarget
  const max = Number(input.dataset.counterMax)
  const label = document.querySelector(`[data-counter-for="${name}"]`)
  if (!label) return
  const current = input.value.length
  const currentEl = label.querySelector('[data-counter-current]')
  if (currentEl) currentEl.textContent = current
  const ratio = current / max
  label.classList.remove('text-[#888888]', 'text-[#D4A017]', 'text-[#DC2626]')
  if (ratio >= 1) {
    label.classList.add('text-[#DC2626]')
  } else if (ratio >= 0.8) {
    label.classList.add('text-[#D4A017]')
  } else {
    label.classList.add('text-[#888888]')
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
