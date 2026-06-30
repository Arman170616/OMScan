<div align="center">

<img src="assets/images/app_icon.png" alt="OMScan Logo" width="120" height="120" style="border-radius: 24px"/>

# OMScan

**Mobile Point of Sale — Flutter App**

[![Download APK](https://img.shields.io/badge/Download-APK-brightgreen?style=for-the-badge&logo=android)](https://github.com/Arman170616/OMScan/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-blue?style=for-the-badge&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)](LICENSE)

</div>

---

## Screenshots

<div align="center">

| Scanner | Inventory | Checkout | Dashboard |
|:-------:|:---------:|:--------:|:---------:|
| <img src="screenshots/scanner.png" width="200"/> | <img src="screenshots/inventory.png" width="200"/> | <img src="screenshots/checkout.png" width="200"/> | <img src="screenshots/dashboard.png" width="200"/> |
| Scan barcodes to add items | Manage your product catalog | Review cart & pay | Track daily sales |

</div>

---

## Download APK

<div align="center">

[![Download Latest APK](https://img.shields.io/badge/⬇️%20Download%20APK-v1.0.0-brightgreen?style=for-the-badge&logo=android&logoColor=white)](https://github.com/Arman170616/OMScan/releases/latest)

</div>

**Install on Android:**
1. Download `app-release.apk` from the [Releases page](https://github.com/Arman170616/OMScan/releases/latest)
2. Enable **Install from unknown sources** in Android Settings → Security
3. Open the downloaded APK and tap Install

---

## App Icon

<div align="center">
<img src="assets/images/app_icon.png" alt="OMScan App Icon" width="100"/>
<br/>
<em>OMScan — Karisma POS</em>
</div>

---

## Features

- **Barcode Scanner** — Scan product barcodes using the device camera to instantly add items to cart
- **Inventory Management** — Add, edit, restock, and delete products with category tagging
- **Checkout** — Review cart, select payment method, confirm payment, and print receipt
- **Bluetooth Printing** — Connect to thermal Bluetooth printers and print invoices on the spot
- **PDF Invoice** — Download a PDF invoice for any completed transaction
- **Sales Dashboard** — View revenue, order count, and sales charts by week / month / year
- **Bilingual UI** — Full Arabic (RTL) and English (LTR) support, switchable at runtime

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x / Dart 3.x |
| State Management | Provider (`ChangeNotifier`) |
| Local Database | SQLite via `sqflite` |
| Barcode Scanning | `mobile_scanner` |
| Bluetooth Printing | `flutter_bluetooth_serial` |
| PDF Generation | `pdf` + `printing` |
| Fonts | Google Fonts — Cairo (Arabic + Latin) |

---

## Project Structure

```
lib/
├── main.dart                  # App entry, providers, MaterialApp
├── models/
│   ├── product.dart           # Product & ProductCategory models + extensions
│   └── cart_item.dart         # CartItem & Order models
├── providers/
│   ├── cart_provider.dart     # Cart state (add/remove/confirm payment)
│   ├── language_provider.dart # Language toggle (AR / EN)
│   └── printer_service.dart   # Bluetooth printer state
├── screens/
│   ├── scanner_screen.dart    # Barcode scan + live cart panel
│   ├── home_screen.dart       # Inventory list + add/edit/restock
│   ├── checkout_screen.dart   # Order summary + payment + printing
│   └── dashboard_screen.dart  # Sales analytics
├── utils/
│   ├── database_helper.dart   # SQLite CRUD operations
│   ├── invoice_service.dart   # PDF invoice builder
│   ├── formatter.dart         # Currency & date formatters
│   └── l10n.dart              # Bilingual string class (AR/EN)
├── widgets/
│   ├── glass_container.dart   # Frosted glass UI component
│   └── product_card.dart      # Product grid card
└── theme/
    └── app_theme.dart         # Color palette & text styles
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Android SDK / Xcode (for iOS)
- A physical Android device is recommended for camera and Bluetooth features

### Setup

```bash
# Clone the repository
git clone https://github.com/Arman170616/OMScan.git
cd OMScan

# Install dependencies
flutter pub get

# Run on a connected device
flutter run

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## Payment Methods

| Key | Arabic | English |
|-----|--------|---------|
| Cash | نقد | Cash |
| Card | بطاقة | Card |
| QRIS | رمز QR | QRIS |
| Bank Transfer | تحويل بنكي | Bank Transfer |

---

## Language Support

Tap the **AR \| EN** toggle in the top bar on any screen to switch languages. The entire UI — including text direction (RTL/LTR), labels, charts, and payment method names — updates instantly without restarting the app.

---

## Permissions Required

| Permission | Purpose |
|-----------|---------|
| `CAMERA` | Barcode scanning |
| `BLUETOOTH` / `BLUETOOTH_CONNECT` | Thermal printer connection |
| `WRITE_EXTERNAL_STORAGE` | PDF invoice download (Android < 10) |

---

<div align="center">

Made with ❤️ for **Karisma** — © 2025 All rights reserved.

</div>
