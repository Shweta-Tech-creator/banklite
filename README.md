# 🏦 BankLite — Simple. Secure. Smarter Banking.

[![Flutter](https://img.shields.io/badge/Flutter-v3.29.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Figma](https://img.shields.io/badge/Design-Figma-F24E1E?logo=figma&logoColor=white)](https://www.figma.com/design/0ni6rdyIogiQTzIvoB65dM/banklite?node-id=0-1&t=tdvMffsIun8SiRXt-1)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> A simplified Flutter banking app for transfers, bills, budgets & statements — powered by Firebase.

<p align="center">
  <a href="https://banklite-f95a6.web.app">
    <img src="https://img.shields.io/badge/🚀%20Live%20Demo-BankLite%20Web%20App-4285F4?style=for-the-badge&logo=firebase&logoColor=white" alt="Live Demo" />
  </a>
  &nbsp;&nbsp;
  <a href="https://www.figma.com/design/0ni6rdyIogiQTzIvoB65dM/banklite?node-id=0-1&t=tdvMffsIun8SiRXt-1">
    <img src="https://img.shields.io/badge/🎨%20Figma%20Prototype-View%20Design-F24E1E?style=for-the-badge&logo=figma&logoColor=white" alt="Figma Design" />
  </a>
</p>

---

## 📱 App Interface

### Core Banking Flow
| Home Dashboard | Transfer Funds | Pay Utility Bills | Budget Insights |
| :---: | :---: | :---: | :---: |
| <img src="screenshots/02_dashboard_screen.png" width="220" alt="Home Dashboard" /> | <img src="screenshots/03_transfer_screen.png" width="220" alt="Transfer Funds" /> | <img src="screenshots/04_bills_screen.png" width="220" alt="Pay Utility Bills" /> | <img src="screenshots/07_budget_screen.png" width="220" alt="Budget Insights" /> |

### Statements, Ledger & Security
| Activity & History | Account Statement | User Profile | Login & Biometrics |
| :---: | :---: | :---: | :---: |
| <img src="screenshots/05_transactions_screen.png" width="220" alt="Activity & History" /> | <img src="screenshots/06_statement_screen.png" width="220" alt="Account Statement" /> | <img src="screenshots/08_profile_screen.png" width="220" alt="User Profile" /> | <img src="screenshots/01_login_screen.png" width="220" alt="Login & Biometrics" /> |

---

## ✨ Features

| Feature | Details |
|---|---|
| 💳 **Clean Dashboard** | Dual-account switching, balance hide/show toggle, spending goal bar |
| 💸 **Fast Transfers** | Beneficiary carousel, quick amount chips (₹500–₹5000), instant validation |
| 💡 **Utility Bills** | Electricity, Mobile, Broadband, Water — with fee breakdown & ledger logging |
| 📊 **Budget Insights** | Category-wise spending bars (Food, Shopping, Bills, Travel) |
| 📄 **PDF & Excel Statements** | Certified e-statements with date filters, downloadable on-device |
| 🔍 **Searchable Ledger** | Filter by All / Income / Expense / Bills, live search by payee or reference ID |
| 🔐 **Security** | Firebase Auth, biometric unlock, 256-bit session, KYC badge |
| ☁️ **Firebase Firestore** | All data (accounts, transactions, bills, statements) stored per-user in cloud |

---

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.29 (Dart 3.7) — cross-platform (iOS, Android, Web, macOS)
- **Backend**: Firebase Auth + Cloud Firestore (real-time, per-user data isolation)
- **Exports**: Client-side PDF & Excel (CSV) generation in Dart — no server needed
- **State**: `ChangeNotifier` + `InheritedWidget` with local `SharedPreferences` cache fallback

---

## 🚀 Run Locally

```bash
git clone https://github.com/Shweta-Tech-creator/banklite.git
cd banklite
flutter pub get
flutter run -d chrome   # Web
flutter run             # Mobile
```

> **Demo login**: `sweta3@gmail.com` / `123456` — or tap the **Biometric** button

---

## 🧪 Tests

```bash
flutter test
```

---

## 🎨 Figma Design

👉 **[Open BankLite on Figma](https://www.figma.com/design/0ni6rdyIogiQTzIvoB65dM/banklite?node-id=0-1&t=tdvMffsIun8SiRXt-1)**

---

## 📜 License

Released under the [MIT License](LICENSE).

