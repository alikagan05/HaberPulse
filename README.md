# 📰 HaberPulse — Veri Odaklı Akıllı Haber Okuyucu

![iOS 17.4+](https://img.shields.io/badge/iOS-17.4%2B-blue?logo=apple&logoColor=white)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-purple)
![Core Data](https://img.shields.io/badge/Storage-Core%20Data-green)
![Apple Translation](https://img.shields.io/badge/Framework-Apple%20Translation-black?logo=apple)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**HaberPulse**, küresel ve yerel haber kaynaklarını tek bir modern arayüzde birleştiren, dinamik sayfalama, çoklu kaynak filtreleme, çevrimdışı okuma ve **Apple Translation Framework** ile yerel dil çevirisi sunan modern bir iOS uygulamasıdır.

---

## ✨ Öne Çıkan Özellikler

- 🌐 **Çoklu Haber Kaynağı Desteği (Multi-Source Aggregation):**
  - **The Guardian API** (REST API - Global içerikler)
  - **TRT Haber** (RSS / XML Akışı)
  - **BBC Türkçe** (RSS / XML Akışı)
  - **NTV** (RSS / XML Akışı)
  - **Webtekno** (Teknoloji & Bilim RSS)
  - **"Tüm Kaynaklar"** modunda tüm haberler eşzamanlı çekilerek tarihe göre sıralanır.

- 🍏 **Apple Translation Framework Entegrasyonu:**
  - İngilizce haberler, iOS 17.4+ yerel `Translation` kütüphanesi (`.translationTask`) ile cihaz üzerinde/Apple güvenli bulutuyla tek tıkla Türkçe'ye çevrilir.
  - Çevrilen makaleler Core Data'ya kaydedilir (sıfır gecikme & kota tasarrufu).

- 🗄️ **Çevrimdışı Okuma & Veri Kalıcılığı (Core Data):**
  - Beğenilen makaleleri yerel hafızaya kaydetme (Bookmarks).
  - Okunan makalelerin otomatik geçmişe kaydedilmesi (History).
  - İnternet bağlantısı olmasa bile kaydedilen makaleleri tam metin okuyabilme.

- 🇹🇷 / 🇬🇧 **Dinamik Uygulama Dili (In-App Localization):**
  - Sistem dilinden bağımsız olarak uygulama içerisinden tek dokunuşla Türkçe ve İngilizce arasında geçiş.

- 🔍 **Arama & Gelişmiş Filtreleme:**
  - Gerçek zamanlı arama motoru (Search with Debounce).
  - Kategoriye ve tarih aralığına göre dinamik filtreleme.

- ⚡ **Akıllı Yaşam Döngüsü (Smart Lifecycle):**
  - Pull-to-Refresh ile anlık yenileme.
  - Sayfa sonuna yaklaşıldığında otomatik sonsuz sayfalama (Infinite Scroll).
  - Uygulama arka plandan ön plana döndüğünde eskiyse otomatik tazeleme (`scenePhase`).

---

## 🏛️ Mimari & Teknoloji Yığını

```
HaberPulse
├── App                    # Uygulama Başlangıcı, DI Container & Secrets
│   ├── HaberPulseApp.swift
│   ├── AppEnvironment.swift
│   └── Secrets.swift.example
│
├── Core                   # Çekirdek Servisler, Ağ & Yardımcılar
│   ├── Networking         # APIClient (REST), RSSClient (XMLParser), Endpoints
│   ├── Services           # TranslationManager, LanguageManager
│   ├── Storage            # PersistenceController (Core Data)
│   ├── Extensions         # Color, Date, String Formatters
│   └── Utilities          # AppLogger (OSLog)
│
├── Features               # MVVM Modülleri
│   ├── Feed               # Akış, Çoklu Kaynak Filtresi, Kart Görünümleri
│   ├── Detail             # Makale Detayı & Apple Translation Entegrasyonu
│   ├── Search             # Arama ve Kategori Filtreleme
│   ├── Bookmarks          # Çevrimdışı Kaydedilenler
│   └── History            # Okuma Geçmişi
│
├── UIComponents           # Tekrar Kullanılabilir Kart, Yükleme & Hata Bileşenleri
└── Resources              # String Catalog / Yerelleştirme (tr, en)
```

- **Mimari:** MVVM (Model-View-ViewModel) + Dependency Injection Container
- **Eşzamanlılık (Concurrency):** Swift 6 Strict Concurrency, `async/await`, `Actors`, `@MainActor`
- **Ağ:** `URLSession` + `JSONDecoder` (REST) & `XMLParser` (RSS)
- **Kalıcılık:** Core Data (`NSPersistentContainer`)
- **Günlükleme:** `OSLog` (`Logger`)

---

## 🚀 Kurulum ve Çalıştırma

1. Projeyi klonlayın:
   ```bash
   git clone https://github.com/alikagan05/HaberPulse.git
   cd HaberPulse
   ```

2. [The Guardian Open Platform](https://open-platform.theguardian.com/access/)'dan ücretsiz bir API anahtarı alın.

3. `HaberPulse/App` dizinindeki `Secrets.swift.example` dosyasını `Secrets.swift` olarak kopyalayın ve anahtarınızı ekleyin:
   ```swift
   enum Secrets {
       static let guardianAPIKey = "BURAYA_API_ANAHTARINIZI_YAZIN"
   }
   ```

4. `HaberPulse.xcodeproj` dosyasını Xcode 16+ ile açın ve `⌘+R` ile derleyip çalıştırın.

---

## 🧪 Testler

Uygulama `HaberPulseTests` altında API istemcisi, RSS ayrıştırıcı, Core Data modelleri ve ViewModel mantığını kapsayan birim testlere sahiptir:
```bash
# Xcode üzerinden
⌘ + U
```

---

## 📄 Lisans

Bu proje MIT Lisansı ile lisanslanmıştır.
