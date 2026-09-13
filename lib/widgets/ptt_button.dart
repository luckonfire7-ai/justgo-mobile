import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';

class PttControls extends StatefulWidget {
  // onPttHold: true saat ditekan, false saat dilepas (tahan-bicara)
  final void Function(bool holding) onPttHold;
  // onOpenMicToggle: true = mic dinyalakan terus, false = dimatikan
  final void Function(bool open) onOpenMicToggle;

  const PttControls({
    super.key,
    required this.onPttHold,
    required this.onOpenMicToggle,
  });

  @override
  State<PttControls> createState() => _PttControlsState();
}

class _PttControlsState extends State<PttControls> {
  bool _pttHolding = false;
  bool _micOpen = false;

  void _setPtt(bool holding) {
    // kalau mic terus-menerus sedang aktif, PTT tidak dipakai bersamaan
    if (_micOpen) return;
    setState(() => _pttHolding = holding);
    // Getar pendek sebagai konfirmasi non-visual - penting karena rider
    // tidak selalu bisa lihat layar tiap saat.
    HapticFeedback.mediumImpact();
    widget.onPttHold(holding);
  }

  void _toggleOpenMic() {
    setState(() => _micOpen = !_micOpen);
    HapticFeedback.mediumImpact();
    widget.onOpenMicToggle(_micOpen);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: JustGoColors.surfaceDarker,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: JustGoColors.border),
      ),
      child: Row(
        children: [
          // Tombol 1: Push-to-talk - hanya aktif selama ditekan
          // Ukuran 68px (bukan 60) - target sentuh lebih besar untuk dipakai
          // sambil pakai sarung tangan riding.
          Expanded(
            child: GestureDetector(
              onLongPressStart: (_) => _setPtt(true),
              onLongPressEnd: (_) => _setPtt(false),
              onLongPressCancel: () => _setPtt(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 68,
                decoration: BoxDecoration(
                  color: _pttHolding ? JustGoColors.white : JustGoColors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _pttHolding ? Icons.mic : Icons.mic_none,
                      color: JustGoColors.black,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _pttHolding ? 'Sedang bicara...' : 'Tahan untuk bicara',
                      style: const TextStyle(
                        color: JustGoColors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Tombol 2: Mic terus-menerus - toggle on/off, tanpa perlu ditahan
          Expanded(
            child: GestureDetector(
              onTap: _toggleOpenMic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 68,
                decoration: BoxDecoration(
                  color: _micOpen ? JustGoColors.orange : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _micOpen ? JustGoColors.orange : JustGoColors.white,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.podcasts,
                      color: _micOpen ? JustGoColors.black : JustGoColors.white,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _micOpen ? 'Mic aktif (tap stop)' : 'Mic terus-menerus',
                      style: TextStyle(
                        color: _micOpen ? JustGoColors.black : JustGoColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
