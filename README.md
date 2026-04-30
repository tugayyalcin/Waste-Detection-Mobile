# ♻️ Waste Detection Mobile App

Bu proje, mobil cihazların kamerasını kullanarak gerçek zamanlı atık tespiti ve sınıflandırması yapan yapay zeka destekli bir Flutter uygulamasıdır. Arka planda eğitilmiş **YOLOv11m** modelinin TFLite (TensorFlow Lite) formatı kullanılarak cihaz üzerinde (on-device) hızlı ve yüksek doğruluklu nesne tespiti sağlanmaktadır.

## 🚀 Özellikler (Features)
* **Gerçek Zamanlı Tespit:** Kamera üzerinden canlı görüntü işleme ve anında sınıflandırma.
* **On-Device AI:** İnternet bağlantısına gerek duymadan `yolo.tflite` modeli ile cihaz üzerinde çıkarım (inference) yapabilme.
* **Çapraz Platform:** Flutter altyapısı sayesinde Android ve iOS desteği.

## 🛠️ Kullanılan Teknolojiler (Tech Stack)
* **Mobil Çerçeve (Framework):** Flutter, Dart
* **Yapay Zeka Modeli:** YOLOv11m (TensorFlow Lite `.tflite` formatına dönüştürülmüş)

## ⚙️ Kurulum ve Çalıştırma (Getting Started)

Proje standart bir Flutter uygulaması olarak çalışmaktadır. Kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

**1. Repoyu Klonlayın:**
```bash
git clone [https://github.com/tugayyalcin/Waste-Detection-Mobile.git](https://github.com/tugayyalcin/Waste-Detection-Mobile.git)
cd Waste-Detection-Mobile
```
**2. Gerekli Paketleri Yükleyin::** 
```bash
flutter pub get
```

**3. Uygulamayı Çalıştırın:**
```bash
flutter run
```
