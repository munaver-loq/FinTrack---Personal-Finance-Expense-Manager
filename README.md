# 💰 FinTrack – Personal Finance & Expense Manager

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-2D3748?style=for-the-badge&logo=flutter&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-6750A4?style=for-the-badge&logo=materialdesign&logoColor=white)

**FinTrack** is an offline-first mobile application designed for budgeting, intuitive expense tracking, and spending pattern analytics with interactive graphical charts.

---

## ✨ Key Features

- **Offline-First Storage:** Local SQLite persistence for fast, reliable, and instant data access without requiring an internet connection.
- **Interactive Analytics:** Visual spending breakdown using pie charts and bar trends powered by `fl_chart`.
- **Smart Budgeting:** Set category-wise expense limits with warning threshold alerts to stay on top of your budget.
- **Modern UI/UX:** Fluid dark mode theme built with clean Material 3 design principles.

---

## 🏗️ Architecture & Tech Stack

- **Framework:** Flutter & Dart
- **State Management:** Riverpod
- **Architecture:** MVVM (Model-View-ViewModel)
- **Local Database:** SQLite
- **Charts & Visualization:** FL Chart
- **Design System:** Material 3

---

## 📱 Screenshots

> *(Add your app screenshots here)*

| Dashboard | Analytics | Budget Limits |
| :---: | :---: | :---: |
| ![Dashboard](assets/screenshots/dashboard.png) | ![Analytics](assets/screenshots/analytics.png) | ![Budgets](assets/screenshots/budgets.png) |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine
- Android Studio / VS Code with Flutter & Dart plugins

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YOUR_USERNAME/fintrack.git](https://github.com/YOUR_USERNAME/fintrack.git)
   cd fintrack

   flutter pub get

   flutter run

   lib/
├── core/           # Theme, constants, utilities
├── data/           # SQLite database helper, models, repositories
├── providers/      # Riverpod state providers
├── viewmodels/     # Business logic & state management (MVVM)
├── views/          # UI screens & reusable widgets
└── main.dart       # App entry point
