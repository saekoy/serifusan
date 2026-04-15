# Pin npm packages by running ./bin/importmap

pin "application"
pin "firebase", to: "firebase.js"

# Firebase SDK — gstatic CDN（Firebase公式が提供するESM版）
pin "firebase/app", to: "https://www.gstatic.com/firebasejs/11.0.2/firebase-app.js"
pin "firebase/auth", to: "https://www.gstatic.com/firebasejs/11.0.2/firebase-auth.js"
