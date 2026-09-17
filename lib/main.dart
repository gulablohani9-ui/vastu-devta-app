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

  // 32 outer padas, clockwise, matching the supplied VastuEnergetics-style
  // presentation: top row 25..32,1; right 2..9; bottom 10..17;
  // left 18..24 (with 25 returning to the top-left).
  final perimeter = <int>[];
  for (int c = 0; c < 9; c++) perimeter.add(c);
  for (int r = 1; r < 9; r++) perimeter.add(r * 9 + 8);
  for (int c = 7; c >= 0; c--) perimeter.add(8 * 9 + c);
  for (int r = 7; r >= 1; r--) perimeter.add(r * 9);
  final outerNos = <int>[25,26,27,28,29,30,31,32,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24];
  for (int i = 0; i < perimeter.length; i++) m[perimeter[i]] = byNo[outerNos[i]]!;

  // Inner ring. Each of the four directional deities occupies a 3-pada
  // strip, and each corner has two 1-pada deities. This is intentionally
  // contiguous so labels never jump to a misleading centroid.
  // North inner strip (row 2): Prithvidhar
  for (final c in [3,4,5]) m[2 * 9 + c] = byNo[33]!;
  // East inner strip (column 6): Aryama
  for (final r in [3,4,5]) m[r * 9 + 6] = byNo[34]!;
  // South inner strip (row 6): Vivaswan
  for (final c in [3,4,5]) m[6 * 9 + c] = byNo[35]!;
  // West inner strip (column 2): Mitra
  for (final r in [3,4,5]) m[r * 9 + 2] = byNo[36]!;

  // Inner corner padas, using the positions visible in the supplied
  // reference: NW Rudra/Rudrajaya, NE Apa/Apavatsa, SE Savita/Savitra,
  // SW Indra/Indrajaya.
  m[2 * 9 + 2] = byNo[43]!; // Rudra
  m[2 * 9 + 3] = byNo[44]!; // Rudrajaya
  m[2 * 9 + 5] = byNo[37]!; // Apa
  m[2 * 9 + 6] = byNo[38]!; // Apavatsa (overrides strip edge cell)
  m[6 * 9 + 6] = byNo[39]!; // Savita
  m[6 * 9 + 5] = byNo[40]!; // Savitra
  m[6 * 9 + 2] = byNo[41]!; // Indra
  m[6 * 9 + 3] = byNo[42]!; // Indrajaya

  // Brahma occupies the central 3x3 block.
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
                      CustomPaint(size: size, painter: PlotPainter(points, northController.text, selectedCell, cellDevta, selectedPoint, double.tryParse(widthController.text) ?? 18, double.tryParse(lengthController.text) ?? 22)),
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
  final double plotWidth;
  final double plotLength;
  PlotPainter(this.points, this.northDegree, this.selectedCell, this.mapping, this.selectedPoint, this.plotWidth, this.plotLength);

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
    canvas.drawPath(path, Paint()..style = PaintingStyle.fill..color = Colors.white.withOpacity(.10));
    canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = Colors.green.shade700);

    // The entered degree is the Vastu/Mandala orientation.  IMPORTANT:
    // rotate only the construction geometry, never the labels themselves.
    final minX = poly.map((q) => q.dx).reduce(math.min);
    final maxX = poly.map((q) => q.dx).reduce(math.max);
    final minY = poly.map((q) => q.dy).reduce(math.min);
    final maxY = poly.map((q) => q.dy).reduce(math.max);
    final center = Offset((minX + maxX) / 2, (minY + maxY) / 2);

    final plotW = plotWidth > 0 ? plotWidth : 18.0;
    final plotH = plotLength > 0 ? plotLength : 22.0;
    final aspect = plotW / plotH;
    // Fit the VPM rectangle inside the photo area while preserving entered ratio.
    double rectH = maxY - minY;
    double rectW = rectH * aspect;
    if (rectW > (maxX - minX) * .96) {
      rectW = (maxX - minX) * .96;
      rectH = rectW / aspect;
    }

    final degValue = double.tryParse(northDegree) ?? 0;
    // Degree is the compass bearing of North in the photo. The Mandala must
    // be rotated in the opposite direction to align its North with that
    // bearing. Keeping this conversion explicit avoids the apparent
    // 'scrambling' seen when a raw bearing is used as a visual rotation.
    final deg = -degValue * math.pi / 180.0;

    canvas.save();
    canvas.clipPath(path);
    canvas.translate(center.dx, center.dy);
    canvas.rotate(deg);
    canvas.translate(-center.dx, -center.dy);

    final left = center.dx - rectW / 2;
    final top = center.dy - rectH / 2;
    final cellW = rectW / 9;
    final cellH = rectH / 9;
    final gridPaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = Colors.white.withOpacity(.92);

    // Draw the complete 9x9 geometry first.
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final idx = r * 9 + c;
        final a = Offset(left + c * cellW, top + r * cellH);
        final b = Offset(left + (c + 1) * cellW, top + r * cellH);
        final cc = Offset(left + (c + 1) * cellW, top + (r + 1) * cellH);
        final d = Offset(left + c * cellW, top + (r + 1) * cellH);
        final cellPath = Path()..moveTo(a.dx, a.dy)..lineTo(b.dx, b.dy)..lineTo(cc.dx, cc.dy)..lineTo(d.dx, d.dy)..close();
        if (selectedCell == idx) {
          canvas.drawPath(cellPath, Paint()..style = PaintingStyle.fill..color = Colors.yellow.withOpacity(.45));
        }
        canvas.drawPath(cellPath, gridPaint);
      }
    }

    // Only the 45 Devata numbers are printed on the plot.  The 81 pada numbers
    // are intentionally NOT printed here because they obscure the plot photo.
    // Each Devata number is placed once at the centre of its mapped padas.
    // Draw each Devata exactly once at a stable anchor cell. Text is kept
    // upright relative to the phone/photo, even while the VPM geometry turns.
    final anchor = <int, Offset>{};
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final idx = r * 9 + c;
        final dta = mapping[idx];
        if (dta == null || anchor.containsKey(dta.no)) continue;
        anchor[dta.no] = Offset(left + (c + .5) * cellW, top + (r + .5) * cellH);
      }
    }
    for (final dta in devtas) {
      final pos = anchor[dta.no];
      if (pos == null) continue;
      final fs = dta.no == 45 ? 15.0 : 10.5;
      _uprightText(
        canvas,
        '${dta.no}',
        pos,
        0,
        TextStyle(color: dta.no == 45 ? Colors.red.shade900 : Colors.black, fontSize: fs, fontWeight: FontWeight.w800, shadows: const [Shadow(blurRadius: 2, color: Colors.white)]),
        maxWidth: 35,
      );
    }
    canvas.restore();

    // Direction markers are kept upright and placed relative to the rotated
    // VPM rectangle, so changing the degree does not twist the text.
    final topDir = _rotated(Offset(center.dx, center.dy - rectH / 2 - 18), center, deg);
    final bottomDir = _rotated(Offset(center.dx, center.dy + rectH / 2 + 18), center, deg);
    final leftDir = _rotated(Offset(center.dx - rectW / 2 - 18, center.dy), center, deg);
    final rightDir = _rotated(Offset(center.dx + rectW / 2 + 18, center.dy), center, deg);
    _uprightText(canvas, 'N', topDir, 0, TextStyle(color: Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.bold));
    _uprightText(canvas, 'S', bottomDir, 0, TextStyle(color: Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.bold));
    _uprightText(canvas, 'W', leftDir, 0, TextStyle(color: Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.bold));
    _uprightText(canvas, 'E', rightDir, 0, TextStyle(color: Colors.blue.shade900, fontSize: 13, fontWeight: FontWeight.bold));

    // Editable boundary points always remain on top.
    for (int i = 0; i < poly.length; i++) {
      final o = poly[i];
      canvas.drawCircle(o, 8, Paint()..color = i == selectedPoint ? Colors.orange : Colors.red);
      canvas.drawCircle(o, 10, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = Colors.white);
      _label(canvas, '${i + 1}', o + const Offset(9, -9), Colors.black);
    }
    _label(canvas, 'North rotation: ${northDegree}°  •  ${points.length} boundary points', const Offset(10, 10), Colors.red.shade900);
  }

  Offset _rotated(Offset q, Offset center, double angle) {
    final dx = q.dx - center.dx;
    final dy = q.dy - center.dy;
    final co = math.cos(angle), si = math.sin(angle);
    return Offset(center.dx + dx * co - dy * si, center.dy + dx * si + dy * co);
  }


  void _uprightText(Canvas c, String text, Offset center, double counterRotation, TextStyle style, {double maxWidth = 140}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth);
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(counterRotation);
    tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
    c.restore();
  }

  void _label(Canvas c, String text, Offset o, Color color) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, shadows: const [Shadow(blurRadius: 3, color: Colors.white)])), textDirection: TextDirection.ltr)..layout();
    tp.paint(c, o);
  }

  @override
  bool shouldRepaint(covariant PlotPainter old) => true;
}
