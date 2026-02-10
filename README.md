# Storelytics

**Retail Analytics & Inventory Intelligence System**

A profit tracking, stock monitoring, and business intelligence tool for pharmacy and general store owners — built with Flutter & Firebase.

---

## Overview

Storelytics helps small retail business owners track their inventory, record sales, monitor profits, identify demand patterns, and generate business reports. It's designed specifically for pharmacies and general stores with a clean, modern SaaS dashboard interface.

> **Not an e-commerce or POS system** — Storelytics is a pure analytics and intelligence platform.

---

## Features

### 📊 Analytics Dashboard
- Today's revenue, profit, and sales count
- Weekly revenue chart (interactive)
- Low stock & expiry alerts
- Most sold items ranking

### 📦 Inventory Management
- Add, edit, delete items with full details
- Category filtering and search
- Stock quantity tracking with min-level alerts
- Expiry date monitoring
- Barcode support
- Stock adjustment dialog

### 💰 Sales Tracking
- Record sales with auto-calculated profit
- Revenue, cost, profit, margin display
- Auto stock decrement on sale
- Sales history with color-coded profit/loss

### 📈 Demand Logging
- Track items requested but unavailable
- Auto-increment for repeated requests
- Top demanded items listing

### 📄 Reports (PDF)
- Monthly Sales Report
- Profit Summary Report
- Inventory Status Report
- Demand Analysis Report

### 🔐 Authentication
- Email/Password sign up & sign in
- Email verification
- Password reset
- Role-based access (Owner / Staff / Admin)

### 🛡️ Admin Panel
- Platform overview (users, stores, revenue)
- User management with enable/disable toggle
- All stores listing

---

## Tech Stack

| Layer              | Technology                              |
|:-------------------|:----------------------------------------|
| **Framework**      | Flutter 3.x (Android, iOS, Web)         |
| **Language**       | Dart                                    |
| **Backend**        | Firebase (Auth, Cloud Firestore)        |
| **State Mgmt**     | Riverpod                                |
| **Routing**        | GoRouter                                |
| **Data Models**    | Freezed + json_serializable             |
| **Charts**         | fl_chart                                |
| **PDF Reports**    | pdf + printing                          |
| **UI**             | Material 3, Google Fonts (Inter)        |

---

## Architecture

```
lib/
├── core/                   # Constants, enums, extensions, validators, router
├── features/
│   ├── auth/               # Authentication (models, repos, providers, screens)
│   ├── store/              # Store management
│   ├── inventory/          # Inventory CRUD
│   ├── sales/              # Sales recording & history
│   ├── demand/             # Demand tracking
│   ├── analytics/          # Dashboard & charts
│   ├── reports/            # PDF report generation
│   └── admin/              # Admin panel
├── shared/widgets/         # Reusable UI components
├── theme/                  # Color palette, typography, spacing, themes
└── main.dart               # App entry point
```

Each feature follows **clean architecture**: `data/models`, `data/repositories`, `presentation/providers`, `presentation/screens`.

---

## Getting Started

### Prerequisites
- Flutter SDK ^3.7.0
- Firebase CLI
- A Firebase project

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd storelytics

# Install dependencies
flutter pub get

# Configure Firebase
flutterfire configure --project=YOUR_PROJECT_ID

# Generate Freezed models
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Firebase Setup

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed instructions on configuring Firebase services, security rules, and required indexes.

---

## Theme

Storelytics supports both **light** and **dark** mode with a carefully designed color palette:

| Token        | Light                  | Dark                   |
|:-------------|:-----------------------|:-----------------------|
| Primary      | `#1A2332`              | `#E8ECF0`              |
| Secondary    | `#10B981` (Emerald)    | `#10B981`              |
| Profit       | `#22C55E` (Green)      | `#22C55E`              |
| Loss         | `#EF4444` (Red)        | `#EF4444`              |
| Background   | `#F8FAFC`              | `#0F172A`              |
| Surface      | `#F1F5F9`              | `#1E293B`              |

---

## Subscription Plans

| Plan       | Max Items | Price     |
|:-----------|:----------|:----------|
| Free       | 50        | Free      |
| Starter    | 200       | $4.99/mo  |
| Pro        | 1000      | $12.99/mo |
| Enterprise | Unlimited | $29.99/mo |

---

## License

This project is proprietary. All rights reserved.
