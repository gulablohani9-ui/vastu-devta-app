import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() => runApp(const VastuPlotApp());

class Devta {
  final int no;
  final String name;
  final String hindi;
  final String zone;
  final String note;
  const Devta(this.no, this.name, this.hindi, this.zone, this.note);
}

// Editable reference table. Different Vastu traditions can use different
// spellings/placements, so keep this data easy to change in the source.
const devtas = <Devta>[
  Devta(1, 'Roga', 'रोग', 'North-West', 'Outer boundary deity.'),
  Devta(2, 'Naga', 'नाग', 'North-West / North', 'Outer boundary deity.'),
  Devta(3, 'Mukhya', 'मुख्य', 'North', 'North zone.'),
  Devta(4, 'Bhallat', 'भल्लाट', 'North', 'North zone.'),
  Devta(5, 'Soma', 'सोम', 'North', 'North zone.'),
  Devta(6, 'Bhujag', 'भुजग', 'North-East / North', 'Outer boundary deity.'),
  Devta(7, 'Aditi', 'अदिति', 'North-East', 'Outer boundary deity.'),
  Devta(8, 'Diti', 'दिति', 'North-East', 'Outer boundary deity.'),
  Devta(9, 'Shikhi', 'शिखी', 'North-East / East', 'Outer boundary deity.'),
  Devta(10, 'Parjanya', 'पर्जन्य', 'East-North-East', 'Outer boundary deity.'),
  Devta(11, 'Jayant', 'जयंत', 'East', 'Outer boundary deity.'),
  Devta(12, 'Mahendra', 'महेंद्र', 'East', 'Outer boundary deity.'),
  Devta(13, 'Surya', 'सूर्य', 'East', 'Outer boundary deity.'),
  Devta(14, 'Satya', 'सत्य', 'East-South-East', 'Outer boundary deity.'),
  Devta(15, 'Bhrisha', 'भृश', 'South-East', 'Outer boundary deity.'),
  Devta(16, 'Akash', 'आकाश', 'South-East', 'Outer boundary deity.'),
  Devta(17, 'Anil', 'अनिल', 'South-East / South', 'Outer boundary deity.'),
  Devta(18, 'Pusha', 'पूषा', 'South', 'Outer boundary deity.'),
  Devta(19, 'Vitatha', 'वितथ', 'South', 'Outer boundary deity.'),
  Devta(20, 'Griharakshita', 'गृहक्षत', 'South', 'Outer boundary deity.'),
  Devta(21, 'Yama', 'यम', 'South-South-West', 'Outer boundary deity.'),
  Devta(22, 'Gandharva', 'गंधर्व', 'South-West', 'Outer boundary deity.'),
  Devta(23, 'Bhringraj', 'भृंगराज', 'South-West', 'Outer boundary deity.'),
  Devta(24, 'Mriga', 'मृग', 'South-West', 'Outer boundary deity.'),
  Devta(25, 'Pitra', 'पितृ', 'South-West', 'Outer boundary deity.'),
  Devta(26, 'Dauwarik', 'दौवारिक', 'South-West / West', 'Outer boundary deity.'),
  Devta(27, 'Sugreev', 'सुग्रीव', 'West', 'Outer boundary deity.'),
  Devta(28, 'Pushpadant', 'पुष्पदन्त', 'West', 'Outer boundary deity.'),
  Devta(29, 'Varun', 'वरुण', 'West', 'Outer boundary deity.'),
  Devta(30, 'Asur', 'असुर', 'West-North-West', 'Outer boundary deity.'),
  Devta(31, 'Shosha', 'शोष', 'North-West', 'Outer boundary deity.'),
  Devta(32, 'Papayakshama', 'पापयक्षमा', 'North-West', 'Outer boundary deity.'),
  Devta(33, 'Prithvidhar', 'पृथ्वीधर', 'North inner', 'Inner deity.'),
  Devta(34, 'Aryama', 'अर्यमा', 'East inner', 'Inner deity.'),
  Devta(35, 'Vivaswan', 'विवस्वान', 'South inner', 'Inner deity.'),
  Devta(36, 'Mitra', 'मित्र', 'West inner', 'Inner deity.'),
  Devta(37, 'Apa', 'आप', 'North-East inner', 'Inner deity.'),
  Devta(38, 'Apavatsa', 'आपवत्स', 'North-East inner', 'Inner deity.'),
  Devta(39, 'Savita', 'सविता', 'South-East inner', 'Inner deity.'),
  Devta(40, 'Savitra', 'सावित्र', 'South-East inner', 'Inner deity.'),
  Devta(41, 'Indra', 'इंद्र', 'South-West inner', 'Inner deity.'),
  Devta(42, 'Indrajaya', 'इंद्रजय', 'South-West inner', 'Inner deity.'),
  Devta(43, 'Rudra', 'रुद्र', 'North-West inner', 'Inner deity.'),
  Devta(44, 'Rudrajaya', 'रुद्रजय', 'North-West inner', 'Inner deity.'),
  Devta(45, 'Brahma', 'ब्रह्मा', 'Centre', 'Brahmasthan — central 3×3 padas.'),
];

final Map<int, Devta> cellDevta = _buildCellMap();

Map<int, Devta> _buildCellMap() {
  final m = <int, Devta>{};
  final byNo = {for (final d in devtas) d.no: d};

  // Reference-style VPM numbering: 32 outer padas run clockwise,
  // beginning at the north-east corner as 1 and ending at the north-west
  // corner as 32/25 depending on the traditional presentation.  This app
  // uses the numbered presentation visible in the supplied reference:
  // north-west -> north-east = 25..32,1; east -> south = 2..9;
  // south-east -> south-west = 10..17; west -> north-west = 18..25.
  final perimeter = <int>[];
  for (int c = 0; c < 9; c++) perimeter.add(c); // north
  for (int r = 1; r < 9; r++) perimeter.add(r * 9 + 8); // east
  for (int c = 7; c >= 0; c--) perimeter.add(8 * 9 + c); // south
  for (int r = 7; r >= 1; r--) perimeter.add(r * 9); // west
  final outerNos = <int>[25,26,27,28,29,30,31,32,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24];
  for (int i = 0; i < perimeter.length; i++) m[perimeter[i]] = byNo[outerNos[i]]!;

  // Four corner/inner deity groups and the four cardinal inner groups.
  final inner = <int, int>{
    10: 36, 19: 36, 20: 42, 28: 43, 29: 43, 30: 43, 31: 43, 32: 43, 33: 43,
    14: 33, 23: 44, 24: 44, 25: 44,
    16: 37, 17: 37, 26: 37, 35: 37, 43: 37, 44: 37, 52: 37,
    53: 38, 54: 39, 55: 39, 56: 39, 57: 40,
    66: 40, 67: 40, 68: 40,
    60: 35, 69: 35, 70: 41, 61: 41, 62: 41,
    48: 41, 49: 41,
    21: 37, 39: 34, 40: 34, 41: 34,
  };
  for (final e in inner.entries) m[e.key] = byNo[e.value]!;

  // The reference layout uses four inner corner/side deities around the
  // central Brahma block. Keep the central 3x3 as Brahma (No. 45).
  for (int r = 3; r <= 5; r++) {
    for (int c = 3; c <= 5; c++) m[r * 9 + c] = byNo[45]!;
  }
  return m;
}

class VastuPlotApp extends StatelessWidget {
  const VastuPlotApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vastu Plot Analyzer',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        home: const HomePage(),
      );
}

class PlotPoint {
  double x;
  double y;
  PlotPoint(this.x, this.y);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? imageBytes;
  final points = <PlotPoint>[];
  final northController = TextEditingController(text: '0');
  final widthController = TextEditingController(text: '18');
  final lengthController = TextEditingController(text: '22');
  int? selectedPoint;
  int? selectedCell;
  bool addMode = true;
  int? dragIndex;

  Future<void> pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 95);
    if (p == null) return;
    setState(() {
      imageBytes = null;
      points.clear();
      selectedPoint = null;
      selectedCell = null;
    });
    final b = await p.readAsBytes();
    setState(() => imageBytes = b);
  }

  void resetPoints() => setState(() {
        points.clear();
        selectedPoint = null;
        selectedCell = null;
      });

  void handleTap(Offset pos, Size size) {
    final x = (pos.dx / size.width).clamp(0.0, 1.0);
    final y = (pos.dy / size.height).clamp(0.0, 1.0);
    final near = _nearestPoint(pos, size);
    if (near != null) {
      setState(() => selectedPoint = near);
      return;
    }
    if (addMode) {
      setState(() {
        points.add(PlotPoint(x, y));
        selectedPoint = points.length - 1;
      });
    }
  }

  int? _nearestPoint(Offset pos, Size size) {
    double best = 22;
    int? index;
    for (int i = 0; i < points.length; i++) {
      final p = Offset(points[i].x * size.width, points[i].y * size.height);
      final d = (p - pos).distance;
      if (d < best) {
        best = d;
        index = i;
      }
    }
    return index;
  }

  void dragStart(DragStartDetails d, Size size) {
    dragIndex = _nearestPoint(d.localPosition, size);
    if (dragIndex != null) setState(() => selectedPoint = dragIndex);
  }

  void dragUpdate(DragUpdateDetails d, Size size) {
    if (dragIndex == null) return;
    setState(() {
      points[dragIndex!].x = (d.localPosition.dx / size.width).clamp(0.0, 1.0);
      points[dragIndex!].y = (d.localPosition.dy / size.height).clamp(0.0, 1.0);
    });
  }

  void dragEnd(DragEndDetails _) => dragIndex = null;

  void deleteSelectedPoint() {
    if (selectedPoint == null || points.isEmpty) return;
    setState(() {
      points.removeAt(selectedPoint!);
      selectedPoint = null;
      selectedCell = null;
    });
  }

  Future<void> showPdf() async {
    if (points.length < 3) return;
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
        pw.Text('Vastu Plot Analyzer', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('Plot: ${widthController.text} × ${lengthController.text} ft | North: ${northController.text}°'),
        pw.SizedBox(height: 12),
        pw.Text('Boundary points: ${points.length} (editable polygon)'),
        pw.SizedBox(height: 12),
        pw.Text('9×9 Paramasayika Mandala — Brahmasthan = central 3×3 padas'),
        pw.SizedBox(height: 10),
        pw.Text('The overlay is a geometry visualization. Traditional Vastu interpretations and remedies vary by tradition and practitioner.'),
        pw.SizedBox(height: 14),
        pw.Text('Selected Devata: ${selectedCell == null ? 'None' : (cellDevta[selectedCell!]?.hindi ?? '—')}'),
      ],
    )));
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final enough = points.length >= 3;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vastu Plot Analyzer'),
        actions: [IconButton(onPressed: enough ? showPdf : null, icon: const Icon(Icons.picture_as_pdf))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('1. Plot Photo + Flexible Boundary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                FilledButton.icon(onPressed: pickImage, icon: const Icon(Icons.add_photo_alternate), label: const Text('Plot Photo Select करें')),
                const SizedBox(height: 8),
                Text('आप 4 नहीं, जितने चाहें boundary points डाल सकते हैं: 4, 5, 6, 10, 20…। लाल dots को बाद में drag करके exact जगह पर सेट करें।', style: TextStyle(color: Colors.grey.shade800)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  FilterChip(label: const Text('Add / Move Points'), selected: addMode, onSelected: (v) => setState(() => addMode = v)),
                  OutlinedButton.icon(onPressed: selectedPoint == null ? null : deleteSelectedPoint, icon: const Icon(Icons.delete_outline), label: const Text('Delete Point')),
                  OutlinedButton.icon(onPressed: points.isEmpty ? null : resetPoints, icon: const Icon(Icons.refresh), label: const Text('Reset')),
                ]),
                const SizedBox(height: 8),
                Text('Points: ${points.length}   •   ${points.length < 3 ? 'कम से कम 3 points डालें' : 'Polygon तैयार है'}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          if (imageBytes != null)
            Card(
              child: AspectRatio(
                aspectRatio: 1.35,
                child: LayoutBuilder(builder: (ctx, c) {
                  final size = Size(c.maxWidth, c.maxHeight);
                  return GestureDetector(
                    onTapUp: (d) => handleTap(d.localPosition, size),
                    onPanStart: (d) => dragStart(d, size),
                    onPanUpdate: (d) => dragUpdate(d, size),
                    onPanEnd: dragEnd,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.memory(imageBytes!, fit: BoxFit.fill),
                      CustomPaint(size: size, painter: PlotPainter(points, northController.text, selectedCell, cellDevta, selectedPoint)),
                    ]),
                  );
                }),
              ),
            ),
          if (imageBytes != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text('कैसे करें: पहले plot के चारों/सभी corners पर tap करें → फिर बीच की boundary bends पर tap करके extra dots जोड़ें → किसी red dot को finger/mouse से खींचकर सही position करें।', style: TextStyle(color: Colors.blueGrey.shade800)),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                Row(children: [
                  Expanded(child: TextField(controller: widthController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Plot Width (ft)', border: OutlineInputBorder()))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: lengthController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Plot Length (ft)', border: OutlineInputBorder()))),
                ]),
                const SizedBox(height: 10),
                TextField(controller: northController, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: const InputDecoration(labelText: 'North / Rotation Degree', hintText: 'जैसे 12.5° या -8°', border: OutlineInputBorder()), onChanged: (_) => setState(() {})),
                const SizedBox(height: 8),
                Text('9×9 = 81 Padas | प्रत्येक nominal cell: ${(double.tryParse(widthController.text) ?? 0) / 9} × ${(double.tryParse(lengthController.text) ?? 0) / 9} ft'),
              ]),
            ),
          ),
          if (selectedCell != null) DevtaCard(devta: cellDevta[selectedCell!], cell: selectedCell!),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('45 Devata Reference', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3.3),
                  itemCount: devtas.length,
                  itemBuilder: (_, i) => Text('${devtas[i].no}. ${devtas[i].hindi} (${devtas[i].name})', style: const TextStyle(fontSize: 12)),
                ),
              ]),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: const Text('महत्वपूर्ण: यह app फोटो पर geometric Vastu overlay बनाने के लिए है। Irregular boundary में grid को plot के अंदर clip किया जाता है और cut/partial areas report किए जा सकते हैं। Devata placement/remedy परंपरा के अनुसार बदल सकती है; निर्माण निर्णय qualified Vastu/architectural review के साथ लें।'),
            ),
          ),
        ]),
      ),
    );
  }
}

class DevtaCard extends StatelessWidget {
  final Devta? devta;
  final int cell;
  const DevtaCard({super.key, required this.devta, required this.cell});
  @override
  Widget build(BuildContext context) {
    if (devta == null) return const SizedBox.shrink();
    final brahma = devta!.no == 45;
    return Card(color: brahma ? Colors.green.shade50 : null, child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Pada ${cell + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
      Text('${devta!.hindi}  •  ${devta!.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text('Zone: ${devta!.zone}'),
      const SizedBox(height: 6),
      Text(devta!.note),
      const SizedBox(height: 8),
      const Text('उपाय: इस section में सामान्य/पारंपरिक remedies, crystal और colour suggestions बाद के report module में जोड़े जा सकते हैं। इन्हें वैज्ञानिक उपचार के रूप में न लें।'),
    ])));
  }
}

class PlotPainter extends CustomPainter {
  final List<PlotPoint> points;
  final String northDegree;
  final int? selectedCell;
  final Map<int, Devta> mapping;
  final int? selectedPoint;
  PlotPainter(this.points, this.northDegree, this.selectedCell, this.mapping, this.selectedPoint);

  Offset p(PlotPoint a, Size s) => Offset(a.x * s.width, a.y * s.height);

  bool inside(Offset q, List<Offset> poly) {
    bool c = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final a = poly[i], b = poly[j];
      if (((a.dy > q.dy) != (b.dy > q.dy)) && q.dx < (b.dx - a.dx) * (q.dy - a.dy) / ((b.dy - a.dy) == 0 ? 1e-9 : (b.dy - a.dy)) + a.dx) c = !c;
    }
    return c;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final poly = points.map((e) => p(e, size)).toList();
    if (poly.length < 3) {
      for (int i = 0; i < poly.length; i++) {
        final o = poly[i];
        canvas.drawCircle(o, 9, Paint()..color = i == selectedPoint ? Colors.orange : Colors.red);
        _label(canvas, '${i + 1}', o + const Offset(10, -10), Colors.black);
      }
      _label(canvas, 'Boundary points: tap to add • drag red dots to move', const Offset(12, 12), Colors.black);
      return;
    }

    final path = Path()..moveTo(poly[0].dx, poly[0].dy);
    for (int i = 1; i < poly.length; i++) path.lineTo(poly[i].dx, poly[i].dy);
    path.close();
    canvas.drawPath(path, Paint()..style = PaintingStyle.fill..color = Colors.white.withOpacity(.12));
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.green.shade700);

    // Rotate the Mandala by the supplied North/reference degree.
    final cx = poly.map((p) => p.dx).reduce((a, b) => a + b) / poly.length;
    final cy = poly.map((p) => p.dy).reduce((a, b) => a + b) / poly.length;
    final center = Offset(cx, cy);
    final deg = (double.tryParse(northDegree) ?? 0) * math.pi / 180;
    canvas.save();
    canvas.clipPath(path);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(deg);
    canvas.translate(-center.dx, -center.dy);

    final xs = poly.map((p) => p.dx).toList();
    final ys = poly.map((p) => p.dy).toList();
    final minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min), maxY = ys.reduce(math.max);
    final cellW = (maxX - minX) / 9;
    final cellH = (maxY - minY) / 9;
    final gridPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withOpacity(.95);

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final idx = r * 9 + c;
        final a = Offset(minX + c * cellW, minY + r * cellH);
        final b = Offset(minX + (c + 1) * cellW, minY + r * cellH);
        final cc = Offset(minX + (c + 1) * cellW, minY + (r + 1) * cellH);
        final d = Offset(minX + c * cellW, minY + (r + 1) * cellH);
        final cellPath = Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(cc.dx, cc.dy)..lineTo(d.dx, d.dy)..close();
        final mid = Offset((a.dx + cc.dx) / 2, (a.dy + cc.dy) / 2);
        if (selectedCell == idx) canvas.drawPath(cellPath, Paint()..style = PaintingStyle.fill..color = Colors.yellow.withOpacity(.5));
        canvas.drawPath(cellPath, gridPaint);
        final t = TextPainter(text: TextSpan(text: '${idx + 1}', style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 2, color: Colors.white)])), textDirection: TextDirection.ltr)..layout();
        t.paint(canvas, mid - Offset(t.width / 2, t.height / 2));
        final dta = mapping[idx];
        if (dta != null) {
          final nt = TextPainter(text: TextSpan(text: dta.hindi, style: TextStyle(color: dta.no == 45 ? Colors.red.shade900 : Colors.blue.shade900, fontSize: dta.no == 45 ? 10 : 7, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 2, color: Colors.white)])), textDirection: TextDirection.ltr)..layout(maxWidth: 50);
          nt.paint(canvas, mid + Offset(-nt.width / 2, 7));
        }
      }
    }
    _label(canvas, 'N', Offset(center.dx - 8, minY - 26), Colors.blue.shade900);
    _label(canvas, 'S', Offset(center.dx - 8, maxY + 8), Colors.blue.shade900);
    _label(canvas, 'W', Offset(minX - 28, center.dy - 8), Colors.blue.shade900);
    _label(canvas, 'E', Offset(maxX + 8, center.dy - 8), Colors.blue.shade900);
    canvas.restore();

    // Red editable boundary dots are always visible above the grid.
    for (int i = 0; i < poly.length; i++) {
      final o = poly[i];
      canvas.drawCircle(o, 8, Paint()..color = i == selectedPoint ? Colors.orange : Colors.red);
      canvas.drawCircle(o, 10, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = Colors.white);
      _label(canvas, '${i + 1}', o + const Offset(9, -9), Colors.black);
    }
    _label(canvas, 'North rotation: ${northDegree}°  •  ${points.length} boundary points', const Offset(10, 10), Colors.red.shade900);
  }

  void _label(Canvas c, String text, Offset o, Color color) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 3, color: Colors.white)])), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, o);
  }

  @override
  bool shouldRepaint(covariant PlotPainter old) => true;
}
