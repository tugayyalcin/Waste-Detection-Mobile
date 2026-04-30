import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doğa Dostu Ayrıştırıcı',
      theme: ThemeData(
        brightness: Brightness.light, // Ferah, aydınlık tema
        primaryColor: const Color(0xFF4CAF50), // Yaprak Yeşili
        scaffoldBackgroundColor: const Color(0xFFF1F8E9), // Çok açık yeşil zemin
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: const Color(0xFF8D6E63), // Toprak rengi detaylar
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlutterVision vision;
  final ImagePicker picker = ImagePicker();

  File? _imageFile;
  List<Map<String, dynamic>> detections = [];
  double _imageWidth = 1;
  double _imageHeight = 1;
  bool isLoaded = false;
  bool isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    initModel();
  }

  Future<void> initModel() async {
    vision = FlutterVision();
    await vision.loadYoloModel(
      labels: 'assets/labels.txt',
      modelPath: 'assets/yolo.tflite',
      modelVersion: "yolov8",
      numThreads: 2,
      useGpu: false,
      quantization: false,
    );
    setState(() => isLoaded = true);
  }

  @override
  void dispose() {
    vision.closeYoloModel();
    super.dispose();
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);
    if (image == null) return;

    File file = File(image.path);
    // Resmi yükle ve boyutlarını al
    var decodedImage = await decodeImageFromList(file.readAsBytesSync());

    setState(() {
      _imageFile = file;
      _imageWidth = decodedImage.width.toDouble();
      _imageHeight = decodedImage.height.toDouble();
      detections = [];
      isAnalyzing = true;
    });

    // Analiz başlıyor
    await runYoloOnImage(file);
  }

  Future<void> runYoloOnImage(File imageFile) async {
    Uint8List byte = await imageFile.readAsBytes();
    final result = await vision.yoloOnImage(
      bytesList: byte,
      imageHeight: _imageHeight.toInt(),
      imageWidth: _imageWidth.toInt(),
      iouThreshold: 0.4,
      confThreshold: 0.15, // Hassas algılama
      classThreshold: 0.15,
    );

    if (result.isNotEmpty) {
      List<Map<String, dynamic>> filteredResults = [];
      for (var item in result) {
        double conf = item['box'][4];
        // Cam için özel, diğerleri için standart filtre
        if ((item['tag'] == 'glass' && conf > 0.15) || conf > 0.35) {
          filteredResults.add(item);
        }
      }
      setState(() {
        detections = filteredResults;
        isAnalyzing = false;
      });
    } else {
      setState(() => isAnalyzing = false);
    }
  }

  void resetApp() {
    setState(() {
      _imageFile = null;
      detections = [];
      isAnalyzing = false;
    });
  }

  // --- DOĞA TEMALI RENKLER ---
  Color getClassColor(String className) {
    switch (className.toLowerCase()) {
      case 'glass': return Colors.teal; // Camgöbeği/Turkuaz
      case 'metal': return Colors.blueGrey; // Metalik Gri
      case 'paper': return const Color(0xFF795548); // Kahverengi (Karton)
      case 'plastic': return const Color(0xFF1E88E5); // Plastik Mavisi
      case 'organic': return const Color(0xFF2E7D32); // Koyu Yeşil
      default: return Colors.grey;
    }
  }

  String translateToTurkish(String tag) {
    switch (tag.toLowerCase()) {
      case 'glass': return 'Cam Atık';
      case 'metal': return 'Metal Atık';
      case 'paper': return 'Kağıt Atık';
      case 'plastic': return 'Plastik Atık';
      case 'organic': return 'Organik Atık';
      default: return tag.toUpperCase();
    }
  }

  IconData getClassIcon(String className) {
    switch (className.toLowerCase()) {
      case 'glass': return Icons.wine_bar; 
      case 'metal': return Icons.settings; 
      case 'paper': return Icons.newspaper; 
      case 'plastic': return Icons.local_drink; 
      case 'organic': return Icons.eco; 
      default: return Icons.recycling;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geri Dönüşüm Asistanı", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50), // Ana Yeşil
        elevation: 0,
        leading: _imageFile != null 
          ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: resetApp)
          : null,
      ),
      body: _imageFile == null ? _buildHomeView() : _buildAnalysisView(),
    );
  }

  // --- 1. GİRİŞ EKRANI (Temiz ve Yeşil) ---
  Widget _buildHomeView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
              ),
              child: const Icon(Icons.recycling, size: 100, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 40),
            const Text(
              "Doğayı Koru, Ayrıştır!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Atığın türünü öğrenmek için fotoğrafını çek.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 50),
            
            // Butonlar
            _buildEcoButton(Icons.camera_alt, "Kamerayı Aç", () => pickImage(ImageSource.camera), const Color(0xFF4CAF50)),
            const SizedBox(height: 20),
            _buildEcoButton(Icons.photo_library, "Galeriden Seç", () => pickImage(ImageSource.gallery), const Color(0xFF8D6E63)),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoButton(IconData icon, String text, VoidCallback onTap, Color color) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
        ),
      ),
    );
  }

  // --- 2. ANALİZ EKRANI (Doğru Hizalama) ---
  Widget _buildAnalysisView() {
    return Column(
      children: [
        // Görüntü Alanı
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FittedBox(
                fit: BoxFit.contain, // Resmi ekrana sığdır
                child: SizedBox(
                  width: _imageWidth,
                  height: _imageHeight,
                  child: Stack(
                    children: [
                      Image.file(_imageFile!),
                      // Kutuları Çiz
                      ...detections.map((d) => _buildBox(d)).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Sonuç Kartı
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Analiz Raporu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                    if (isAnalyzing) const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
                const SizedBox(height: 20),
                
                Expanded(
                  child: detections.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isAnalyzing ? Icons.search : Icons.help_outline, size: 50, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text(isAnalyzing ? "Taranıyor..." : "Atık Tespit Edilemedi", style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: detections.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final d = detections[index];
                            final color = getClassColor(d['tag']);
                            final label = translateToTurkish(d['tag']);
                            final icon = getClassIcon(d['tag']);
                            final conf = (d['box'][4] * 100).toStringAsFixed(0);

                            return Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: color.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                                        Text("Eşleşme Oranı: %$conf", style: TextStyle(color: Colors.grey[700])),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.check_circle, color: color),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: resetApp,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Yeni Analiz Yap"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- KUTU ÇİZİMİ ---
  Widget _buildBox(Map<String, dynamic> result) {
    final box = result["box"];
    final color = getClassColor(result['tag']);
    
    return Positioned(
      left: box[0],
      top: box[1],
      width: box[2] - box[0],
      height: box[3] - box[1],
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.2), // Hafif iç dolgu
        ),
      ),
    );
  }
}