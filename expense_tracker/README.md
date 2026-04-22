# 💸 Expense Tracker

A beautiful, feature-rich personal expense tracking Android app built with Flutter. All data stored locally on your device using SQLite.

## ✨ Features

- **Dashboard** – Monthly/yearly totals, top categories, recent expenses
- **Budget Tracking** – Set monthly & yearly limits with animated ring indicators; goes above 100% when exceeded
- **Full Expense Management** – Add, edit, delete expenses with title, amount, category, payment method, date, notes, recurring flag
- **14 Categories** – Food, Transport, Shopping, Entertainment, Health, Utilities, Housing, Education, Travel, Personal Care, Gifts, Subscriptions, Investments, Other
- **9 Payment Methods** – Cash, Credit Card, Debit Card, UPI, Bank Transfer, Crypto, Cheque, BNPL, Other
- **Analytics** – Pie chart for categories, bar chart for payment methods, daily spending line chart
- **Search & Filter** – Search by title/category/note, filter by category or payment method
- **Swipe to Delete/Edit** – Slide expense cards for quick actions
- **Local Storage** – All data stored on device via SQLite (no cloud, no account needed)
- **Dark Theme** – Beautiful deep purple/indigo dark UI

---

## 🚀 Build APK via GitHub Actions

### Step 1: Create a GitHub repository

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/expense-tracker.git
git push -u origin main
```

### Step 2: GitHub Actions builds automatically

Every push to `main`/`master` will:
1. Set up Flutter 3.24 environment
2. Run `flutter pub get`
3. Build a release APK
4. **Upload it as a downloadable artifact** under Actions → your workflow run
5. **Create a GitHub Release** with the APK attached

### Step 3: Download your APK

- Go to your repo → **Actions** tab → click the latest workflow run → scroll to **Artifacts** → download `expense-tracker-apk`
- OR go to **Releases** tab and download from there

### Step 4: Install on Android

1. Transfer the APK to your phone
2. Go to **Settings → Security → Install unknown apps** and allow your browser/file manager
3. Open the APK file and tap Install

---

## 🛠 Local Development

Requirements:
- Flutter SDK 3.24+
- Android Studio or VS Code with Flutter plugin
- Android device or emulator (API 21+)

```bash
flutter pub get
flutter run
```

To build APK locally:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── expense.dart             # Expense & Budget models + constants
├── providers/
│   └── expense_provider.dart    # State management (ChangeNotifier)
├── screens/
│   ├── home_screen.dart         # Navigation shell
│   ├── dashboard_screen.dart    # Home dashboard
│   ├── expenses_screen.dart     # All expenses list
│   ├── add_expense_screen.dart  # Add/edit expense form
│   ├── expense_detail_screen.dart
│   ├── analytics_screen.dart    # Charts & analytics
│   └── budget_screen.dart       # Budget management
├── widgets/
│   ├── expense_card.dart        # Swipeable expense card
│   └── budget_ring.dart         # Circular budget indicator
└── utils/
    ├── app_theme.dart           # Dark theme config
    ├── formatters.dart          # Currency/date formatters
    └── database_helper.dart     # SQLite operations
```

---

## 📝 Currency

Default currency symbol is **₹ (INR)**. To change it, edit `Formatters.currency()` in `lib/utils/formatters.dart`.
