# OMScan — Mobile POS System

A Flutter-based Point of Sale application with barcode scanning, inventory management, and bilingual Arabic/English support.

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
│   ├── printer_service.dart   # Bluetooth print commands
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

## License

This project is proprietary software developed for Karisma. All rights reserved.
