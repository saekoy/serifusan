// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// 生成フォーム送信時にローディングオーバーレイを表示
document.addEventListener('turbo:submit-start', (event) => {
  const form = event.target
  if (!form.action.endsWith('/generations')) return

  const overlay = document.getElementById('loading-overlay')
  if (overlay) overlay.classList.remove('hidden')
})

// 送信終了・キャッシュ復元時に非表示へ戻す
document.addEventListener('turbo:submit-end', () => {
  const overlay = document.getElementById('loading-overlay')
  if (overlay) overlay.classList.add('hidden')
})

document.addEventListener('turbo:load', () => {
  const overlay = document.getElementById('loading-overlay')
  if (overlay) overlay.classList.add('hidden')
})
