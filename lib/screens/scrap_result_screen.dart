import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../design_system/design_system.dart';
import '../mock_data.dart';
import 'recycler_screen.dart';

import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

// ── Confidence threshold ──────────────────────────────────────────────────────
const double _lowConfidenceThreshold = 0.85;

class ScrapResultScreen extends StatefulWidget {
  const ScrapResultScreen({super.key});

  @override
  State<ScrapResultScreen> createState() => _ScrapResultScreenState();
}

class _ScrapResultScreenState extends State<ScrapResultScreen> {
  late double _weight;
  late TextEditingController _ctrl;
  bool _materialConfirmed = false;

  @override
  void initState() {
    super.initState();
    _weight = context.read<AppState>().weightKg;
    _ctrl = TextEditingController(text: _weight.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _adjustWeight(double delta) {
    final newVal = (_weight + delta).clamp(0.5, 999.0);
    setState(() => _weight = newVal);
    context.read<AppState>().setWeight(newVal);
    _ctrl.text = newVal.toStringAsFixed(newVal % 1 == 0 ? 0 : 1);
  }

  Future<void> _showMaterialPicker(BuildContext context) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) =>
          _MaterialPicker(current: context.read<AppState>().scannedMaterial),
    );
    if (chosen != null && context.mounted) {
      context.read<AppState>().setMaterialManually(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final material = state.scannedMaterial;
    final confidence = state.aiConfidence;
    final rate = state.ratePerKg;
    final value = _weight * rate;
    final components = state.detectedComponents;
    final valuation = state.valuation;
    final lowConfidence =
        confidence > 0 && confidence < _lowConfidenceThreshold;

    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: AppBar(
        backgroundColor: _Palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 72,
        leading: _BackBtn(),
        title: Text(
          'Scrap Identified',
          style: AppTypography.sectionHeading.copyWith(
            color: _Palette.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showMaterialPicker(context),
            icon: const Icon(Icons.swap_horiz_rounded, size: 18),
            label: const Text('Change'),
            style: TextButton.styleFrom(foregroundColor: _Palette.green),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _CityIllustration()),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
                12,
                MediaQuery.sizeOf(context).width < 600 ? 16 : 40,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Surface(
                        color: const Color(0xFAFFFCF6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Eyebrow(
                              'KABADIWALA CONNECT  /  MATERIAL REVIEW',
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Your scrap has\nmore to give.',
                              style: AppTypography.headline1.copyWith(
                                fontSize: 32,
                                height: 1.16,
                                color: _Palette.ink,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.9,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Review your scrap. Recover its value. Keep resources in use.',
                              style: AppTypography.body.copyWith(
                                color: _Palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Surface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final photo = _PhotoThumbnail(
                                  imageFile: state.capturedXFile,
                                  material: material,
                                );
                                final details = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _Eyebrow(
                                      '01  /  IDENTIFIED MATERIAL',
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      material,
                                      style: AppTypography.headline1.copyWith(
                                        fontSize: 34,
                                        color: _Palette.ink,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (confidence > 0)
                                      _ConfidenceBadge(
                                        material: material,
                                        confidence: confidence,
                                      )
                                    else
                                      _ManualBadge(material: material),
                                    const SizedBox(height: 12),
                                    Text(
                                      confidence > 0
                                          ? 'AI identification · Please verify the material before continuing.'
                                          : 'You selected this material. Please confirm it before continuing.',
                                      style: AppTypography.body.copyWith(
                                        color: _Palette.muted,
                                      ),
                                    ),
                                    if (lowConfidence) ...[
                                      const SizedBox(height: 16),
                                      _LowConfidenceWarning(
                                        onChangeMaterial: () =>
                                            _showMaterialPicker(context),
                                      ),
                                    ],
                                  ],
                                );
                                if (constraints.maxWidth >= 720) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(flex: 5, child: photo),
                                      const SizedBox(width: 28),
                                      Expanded(flex: 6, child: details),
                                    ],
                                  );
                                }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    photo,
                                    const SizedBox(height: 24),
                                    details,
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _Surface(
                              color: _materialConfirmed
                                  ? _Palette.mint
                                  : Colors.white,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        _materialConfirmed
                                            ? Icons.check_circle_rounded
                                            : Icons.fact_check_outlined,
                                        color: _Palette.green,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _materialConfirmed
                                                  ? 'Material confirmed'
                                                  : 'Please confirm the detected material',
                                              style: AppTypography.label
                                                  .copyWith(
                                                    color: _Palette.ink,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _materialConfirmed
                                                  ? 'Your material is ready for recycler matching.'
                                                  : 'Check that the material above matches your scrap.',
                                              style: AppTypography.caption
                                                  .copyWith(
                                                    color: _Palette.muted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (_materialConfirmed)
                                    _ActionButton(
                                      onPressed: () {},
                                      icon: Icons.check_circle_rounded,
                                      label: 'Confirmed',
                                      outlined: true,
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ActionButton(
                                            onPressed: () {
                                              setState(() {
                                                _materialConfirmed = true;
                                              });
                                            },
                                            icon: Icons.check_rounded,
                                            label: 'Correct',
                                            outlined: false,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _ActionButton(
                                            onPressed: () async {
                                              final chosen = await showModalBottomSheet<String>(
                                                context: context,
                                                backgroundColor: AppColors.white,
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.vertical(
                                                    top: Radius.circular(AppSpacing.radiusLg),
                                                  ),
                                                ),
                                                builder: (_) => _MaterialPicker(current: context.read<AppState>().scannedMaterial),
                                              );
                                              if (chosen != null && context.mounted) {
                                                context.read<AppState>().setMaterialManually(chosen);
                                                await context.read<AppState>().reportCorrection(chosen);
                                                setState(() => _materialConfirmed = true);
                                              }
                                            },
                                            icon: Icons.close_rounded,
                                            label: 'Incorrect',
                                            outlined: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (components.isNotEmpty || valuation != null) ...[
                        const SizedBox(height: 20),
                        _Surface(
                          color: const Color(0xFFF9F6EE),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Eyebrow('AI COMPONENT & GRADING BREAKDOWN'),
                              if (valuation != null) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _Palette.mint,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.verified_outlined,
                                        size: 18,
                                        color: _Palette.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          valuation.grade,
                                          style: AppTypography.label.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: _Palette.dark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (valuation.note.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    valuation.note,
                                    style: AppTypography.caption.copyWith(
                                      color: _Palette.muted,
                                    ),
                                  ),
                                ],
                              ],
                              if (components.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text(
                                  'Identified parts & components:',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _Palette.ink,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: components
                                      .map(
                                        (c) => Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: _Palette.border,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.memory_rounded,
                                                size: 16,
                                                color: _Palette.green,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${c.name} (${c.count}x)',
                                                style: AppTypography.caption
                                                    .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: _Palette.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final rateCard = _RateCard(
                            rate: rate,
                            material: material,
                          );
                          final weightCard = _WeightEditor(
                            weight: _weight,
                            ctrl: _ctrl,
                            onAdjust: _adjustWeight,
                            onChanged: (v) {
                              setState(() => _weight = v);
                              context.read<AppState>().setWeight(v);
                            },
                          );
                          if (constraints.maxWidth >= 720) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: rateCard),
                                const SizedBox(width: 20),
                                Expanded(child: weightCard),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              rateCard,
                              const SizedBox(height: 16),
                              weightCard,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _ValueCard(weight: _weight, rate: rate, value: value),
                      const SizedBox(height: 20),
                      _Surface(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(
                              child: TextButton.icon(
                                onPressed: () => _showMaterialPicker(context),
                                icon: const Icon(Icons.edit_outlined, size: 17),
                                label: const Text('Wrong material? Change it'),
                                style: TextButton.styleFrom(
                                  foregroundColor: _Palette.green,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _ActionButton(
                              label: 'Find Authorized Recycler',
                              icon: Icons.recycling_rounded,
                              onPressed: () {
                                if (!_materialConfirmed) {
                                  setState(() => _materialConfirmed = true);
                                }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RecyclerScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _ActionButton(
                              label: 'Retake Photo',
                              icon: Icons.camera_alt_outlined,
                              outlined: true,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Surface(
                        color: const Color(0xF5EBF2E8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.eco_outlined,
                              color: _Palette.green,
                              size: 26,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'A cleaner city starts here.',
                                    style: AppTypography.label.copyWith(
                                      color: _Palette.dark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Every responsible handover supports a cleaner city.',
                                    style: AppTypography.caption.copyWith(
                                      color: _Palette.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Styling is scoped to this screen; shared theme and behavior stay unchanged.
abstract final class _Palette {
  static const background = Color(0xFFF4EFE4);
  static const ink = Color(0xFF29332E);
  static const muted = Color(0xFF64736B);
  static const green = Color(0xFF176443);
  static const dark = Color(0xFF104B39);
  static const mint = Color(0xFFEDF3E9);
  static const border = Color(0xFFE0E5DA);
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: _Palette.muted,
      fontSize: 11,
      height: 1.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
  );
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child, this.color = const Color(0xFCFFFDF9)});
  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _Palette.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x090F3021),
          blurRadius: 24,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: child,
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.outlined = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool outlined;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: outlined ? Colors.white : _Palette.green,
        foregroundColor: outlined ? _Palette.dark : Colors.white,
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: outlined
            ? const BorderSide(color: _Palette.border)
            : BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.material, required this.confidence});
  final String material;
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).toStringAsFixed(0);
    final isLow = confidence < _lowConfidenceThreshold;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isLow ? const Color(0xFFFFF7E7) : _Palette.mint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLow ? Icons.help_outline_rounded : Icons.check_circle_rounded,
            color: isLow ? const Color(0xFF856404) : _Palette.green,
            size: 16,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$pct% confidence · ${isLow ? 'Review needed' : 'High confidence'}',
              style: AppTypography.label.copyWith(
                color: isLow ? const Color(0xFF856404) : _Palette.dark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManualBadge extends StatelessWidget {
  const _ManualBadge({required this.material});
  final String material;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: _Palette.border,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_rounded, color: _Palette.dark, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$material  ·  Set manually',
              style: AppTypography.label.copyWith(
                color: _Palette.dark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LowConfidenceWarning extends StatelessWidget {
  const _LowConfidenceWarning({required this.onChangeMaterial});
  final VoidCallback onChangeMaterial;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0xFFEAD7B0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF92400E),
                size: 18,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Not sure about this result',
                  style: AppTypography.label.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'The AI is not confident. Please verify or choose the material yourself.',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF92400E),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionButton(
            onPressed: onChangeMaterial,
            icon: Icons.edit_outlined,
            label: 'Choose Material Manually',
            outlined: true,
          ),
        ],
      ),
    );
  }
}

class _WeightEditor extends StatelessWidget {
  const _WeightEditor({
    required this.weight,
    required this.ctrl,
    required this.onAdjust,
    required this.onChanged,
  });
  final double weight;
  final TextEditingController ctrl;
  final void Function(double) onAdjust;
  final void Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Eyebrow('03  /  SCRAP WEIGHT'),
          const SizedBox(height: 6),
          Text(
            'Adjust or enter the weight in kg',
            style: AppTypography.caption.copyWith(color: _Palette.muted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _WeightBtn(icon: Icons.remove, onTap: () => onAdjust(-0.5)),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: AppTypography.headline2.copyWith(
                    color: _Palette.ink,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    semanticCounterText: 'Weight in kilograms',
                    hintText: 'kg',
                    filled: true,
                    fillColor: _Palette.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _Palette.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: _Palette.green,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    if (parsed != null && parsed > 0 && parsed <= 999) {
                      onChanged(parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              _WeightBtn(icon: Icons.add, onTap: () => onAdjust(0.5)),
            ],
          ),
          const SizedBox(height: 10),
          Text('0.5 kg increments', style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.rate, required this.material});
  final double rate;
  final String material;

  @override
  Widget build(BuildContext context) {
    final hasRate = rate > 0;
    return _Surface(
      color: _Palette.mint,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sell_outlined, color: _Palette.green, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow('02  /  FAIR RATE TODAY'),
                const SizedBox(height: 6),
                Text(
                  hasRate
                      ? '₹${rate.toStringAsFixed(0)} / kg'
                      : 'No rate for $material',
                  style: AppTypography.sectionHeading.copyWith(
                    color: hasRate ? _Palette.dark : _Palette.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Price updated today', style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.weight,
    required this.rate,
    required this.value,
  });
  final double weight;
  final double rate;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: _Palette.mint,
        border: Border.all(color: _Palette.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            'Estimated value',
            style: AppTypography.label.copyWith(color: _Palette.dark),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '₹${_fmt(value)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: _Palette.dark,
                height: 1.0,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg × ₹${rate.toStringAsFixed(0)}/kg',
            style: AppTypography.caption.copyWith(color: _Palette.muted),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) {
    final s = v.toInt().toString();
    if (s.length <= 3) return s;
    return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.imageFile, required this.material});

  final XFile? imageFile;
  final String material;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: imageFile?.readAsBytes(),
      builder: (context, snapshot) {
        final bytes = snapshot.data;

        return Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: _Palette.mint,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: _Palette.border, width: 1.5),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd - 1),
                child: bytes != null
                    ? Image.memory(bytes, fit: BoxFit.cover)
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image_rounded,
                              size: 40,
                              color: _Palette.green,
                            ),
                            SizedBox(height: 6),
                            Text(
                              imageFile == null
                                  ? 'No photo available'
                                  : snapshot.hasError
                                  ? 'Photo unavailable'
                                  : 'Loading photo...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: _Palette.muted,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              Positioned(
                bottom: AppSpacing.sm,
                right: AppSpacing.sm,
                left: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _Palette.dark.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          material,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Material picker bottom sheet ──────────────────────────────────────────────

class _MaterialPicker extends StatelessWidget {
  const _MaterialPicker({required this.current});
  final String current;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _Palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Choose Material', style: AppTypography.sectionHeading),
            const SizedBox(height: AppSpacing.md),
            ...allSelectableMaterials.map((m) {
              final selected = m == current;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: selected ? _Palette.mint : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: CircleIconContainer(
                    icon: Icons.recycling_rounded,
                    size: 40,
                    iconSize: 20,
                    backgroundColor: selected
                        ? _Palette.green
                        : _Palette.border,
                    iconColor: selected ? AppColors.white : _Palette.dark,
                  ),
                  title: Text(
                    m,
                    style: AppTypography.label.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? _Palette.dark : _Palette.ink,
                    ),
                  ),
                  subtitle: Text(
                    '₹${rateForMaterial(m).toStringAsFixed(0)}/kg',
                    style: AppTypography.caption,
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_rounded, color: _Palette.green)
                      : null,
                  onTap: () => Navigator.of(context).pop(m),
                ),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ── Shared small widgets ──────────────────────────────────────────────────────

class _BackBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: _Palette.ink,
          size: 22,
        ),
      ),
    );
  }
}

class _WeightBtn extends StatelessWidget {
  const _WeightBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: icon == Icons.add
          ? 'Increase weight by 0.5 kg'
          : 'Decrease weight by 0.5 kg',
      onPressed: onTap,
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: _Palette.mint,
        foregroundColor: _Palette.green,
        side: const BorderSide(color: _Palette.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 24),
    );
  }
}

// Decorative editorial scene: local canvas artwork, no assets or network reads.
// It stays behind nearly opaque cards and never receives pointer events.
class _CityIllustration extends CustomPainter {
  const _CityIllustration();

  @override
  void paint(Canvas canvas, Size size) {
    final paper = Paint()..color = _Palette.background;
    canvas.drawRect(Offset.zero & size, paper);
    // Sparse paper grain, deterministic so rebuilds do not shimmer.
    final grain = Paint()..color = const Color(0x087B6B4B);
    for (var i = 0; i < 1800; i++) {
      final x = ((i * 73.37) % 997) / 997 * size.width;
      final y = ((i * 41.71) % 991) / 991 * size.height;
      canvas.drawCircle(Offset(x, y), i.isEven ? 0.6 : 0.9, grain);
    }
    final scale = (size.width / 1000).clamp(0.65, 1.35);
    canvas.save();
    canvas.translate(0, size.height * 0.30);
    canvas.scale(scale);
    _neighborhood(canvas);
    canvas.restore();
    canvas.save();
    canvas.translate(size.width, size.height * 0.12);
    canvas.scale(-scale, scale);
    _neighborhood(canvas);
    canvas.restore();
    // A soft central wash keeps the content column visually quiet.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0x00F4EFE4),
            Color(0xB8F4EFE4),
            Color(0xB8F4EFE4),
            Color(0x00F4EFE4),
          ],
          stops: [0, 0.27, 0.73, 1],
        ).createShader(Offset.zero & size),
    );
  }

  void _neighborhood(Canvas canvas) {
    final sand = Paint()..color = const Color(0x35B8A181);
    final teal = Paint()..color = const Color(0x35739386);
    final green = Paint()..color = const Color(0x356F8B65);
    final ink = Paint()
      ..color = const Color(0x42717A68)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    // Flat-roof buildings, parapets and rooftop water tanks.
    for (var i = 0; i < 4; i++) {
      final x = i * 58.0 - 28;
      final top = 105.0 + (i % 3) * 43;
      canvas.drawRect(
        Rect.fromLTRB(x, top, x + 52, 420),
        i.isEven ? sand : teal,
      );
      canvas.drawRect(Rect.fromLTWH(x - 3, top, 58, 6), sand);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 12, top - 17, 20, 15),
          const Radius.circular(3),
        ),
        teal,
      );
      for (var row = 0; row < 4; row++) {
        for (var col = 0; col < 2; col++) {
          canvas.drawRect(
            Rect.fromLTWH(x + 10 + col * 23, top + 22 + row * 39, 9, 14),
            Paint()..color = const Color(0x2472705B),
          );
        }
      }
    }
    final wire = Path()
      ..moveTo(0, 198)
      ..quadraticBezierTo(110, 226, 242, 197);
    canvas.drawPath(wire, ink..color = const Color(0x28717A68));
    canvas.drawLine(const Offset(20, 160), const Offset(20, 432), ink);
    // Ground wash and a low compound wall.
    canvas.drawOval(const Rect.fromLTWH(-95, 412, 390, 210), sand);
    final wall = Path()
      ..moveTo(-20, 355)
      ..lineTo(216, 397)
      ..lineTo(216, 451)
      ..lineTo(-20, 438)
      ..close();
    canvas.drawPath(wall, Paint()..color = const Color(0x50D8CBB1));
    canvas.drawLine(const Offset(0, 358), const Offset(217, 398), ink);
    // A hand-pulled collection cart, with sorted scrap and bicycle-style wheels.
    canvas.save();
    canvas.translate(13, 449);
    ink.color = const Color(0x60707A68);
    for (final x in [28.0, 119.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, 58), width: 36, height: 54),
        ink..strokeWidth = 3,
      );
      canvas.drawLine(
        Offset(x - 15, 42),
        Offset(x + 15, 74),
        ink..strokeWidth = 1,
      );
      canvas.drawLine(Offset(x + 15, 42), Offset(x - 15, 74), ink);
      canvas.drawLine(Offset(x, 33), Offset(x, 83), ink);
    }
    canvas.drawRect(const Rect.fromLTWH(0, 0, 142, 48), teal);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 142, 5), green);
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(Offset(8 + i * 29.0, 5), Offset(8 + i * 29.0, 46), ink);
    }
    canvas.drawLine(
      const Offset(137, 11),
      const Offset(185, -3),
      ink..strokeWidth = 3,
    );
    canvas.drawLine(const Offset(-3, 49), const Offset(149, 49), ink);
    canvas.drawRect(const Rect.fromLTWH(9, -23, 37, 23), sand);
    canvas.drawRect(const Rect.fromLTWH(51, -17, 28, 17), green);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(89, -27, 14, 27),
        const Radius.circular(4),
      ),
      teal,
    );
    canvas.drawRect(const Rect.fromLTWH(92, -32, 8, 7), teal);
    canvas.drawLine(
      const Offset(12, -14),
      const Offset(38, -14),
      ink..strokeWidth = 1,
    );
    canvas.restore();
    // Municipal collection bins with a circular-resource mark.
    canvas.save();
    canvas.translate(180, 435);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 43, 64),
        const Radius.circular(5),
      ),
      green,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4, -4, 51, 8),
        const Radius.circular(3),
      ),
      teal,
    );
    canvas.drawCircle(const Offset(8, 65), 4, teal);
    canvas.drawCircle(const Offset(35, 65), 4, teal);
    canvas.drawArc(
      const Rect.fromLTWH(11, 20, 22, 22),
      0.4,
      4.8,
      false,
      ink..strokeWidth = 2,
    );
    canvas.drawPath(
      Path()
        ..moveTo(25, 18)
        ..lineTo(31, 20)
        ..lineTo(28, 26),
      ink,
    );
    canvas.restore();
    // Loose layered foliage softens the built environment.
    for (final tree in [const Offset(-7, 292), const Offset(215, 330)]) {
      canvas.drawPath(
        Path()
          ..moveTo(tree.dx, tree.dy + 154)
          ..quadraticBezierTo(tree.dx + 12, tree.dy + 62, tree.dx - 7, tree.dy),
        ink
          ..strokeWidth = 5
          ..color = const Color(0x387F8066),
      );
      for (var i = 0; i < 34; i++) {
        final dx = ((i * 37) % 97) - 48.0;
        final dy = ((i * 29) % 83) - 46.0;
        canvas.drawOval(
          Rect.fromCenter(
            center: tree + Offset(dx, dy),
            width: 33 + i % 14,
            height: 24 + i % 19,
          ),
          Paint()
            ..color = i % 3 == 0
                ? const Color(0x24779879)
                : const Color(0x267F965F),
        );
      }
    }
    // Small roadside plants.
    for (var i = 0; i < 8; i++) {
      final x = 150 + i * 13.0;
      final y = 562 + (i % 3) * 8.0;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 5, y - 36),
        ink..strokeWidth = 1.5,
      );
      canvas.drawOval(Rect.fromLTWH(x - 18, y - 35, 18, 10), green);
      canvas.drawOval(Rect.fromLTWH(x - 3, y - 25, 20, 11), teal);
    }
  }

  @override
  bool shouldRepaint(covariant _CityIllustration oldDelegate) => false;
}
