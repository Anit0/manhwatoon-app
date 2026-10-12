import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Starts a cooldown when the app launches. After it elapses, the next
/// genuine tap (not a scroll / swipe / drag) opens [AppConstants.adUrl]
/// in the external browser and the cooldown restarts.
class AdScheduler {
  AdScheduler._();

  static final AdScheduler instance = AdScheduler._();

  DateTime? _readyAt;
  bool _opening = false;

  void start() {
    _readyAt = DateTime.now().add(AppConstants.adInterval);
  }

  Future<void> onGenuineTap() async {
    if (_opening) return;
    final readyAt = _readyAt;
    if (readyAt == null || DateTime.now().isBefore(readyAt)) return;

    _opening = true;
    try {
      final uri = Uri.parse(AppConstants.adUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        _readyAt = DateTime.now().add(AppConstants.adInterval);
      }
    } catch (e, st) {
      debugPrint('AdScheduler launch failed: $e\n$st');
    } finally {
      _opening = false;
    }
  }
}

/// Observes pointer events app-wide without joining the gesture arena, so
/// child buttons, lists, and the manga reader keep working.
class AdTapInterceptor extends StatefulWidget {
  const AdTapInterceptor({super.key, required this.child});

  final Widget child;

  @override
  State<AdTapInterceptor> createState() => _AdTapInterceptorState();
}

class _AdTapInterceptorState extends State<AdTapInterceptor> {
  static const double _maxTapSlop = 18;

  int? _pointer;
  Offset? _downPos;
  DateTime? _downAt;
  bool _moved = false;

  @override
  void initState() {
    super.initState();
    AdScheduler.instance.start();
  }

  void _onDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.touch &&
        event.kind != PointerDeviceKind.mouse) {
      return;
    }
    _pointer = event.pointer;
    _downPos = event.position;
    _downAt = DateTime.now();
    _moved = false;
  }

  void _onMove(PointerMoveEvent event) {
    if (event.pointer != _pointer || _downPos == null) return;
    if ((event.position - _downPos!).distance > _maxTapSlop) {
      _moved = true;
    }
  }

  void _onUp(PointerUpEvent event) {
    if (event.pointer != _pointer) return;
    final origin = _downPos;
    final started = _downAt;
    final moved = _moved;
    _resetPointer();
    if (moved || origin == null || started == null) return;
    if ((event.position - origin).distance > _maxTapSlop) return;
    if (DateTime.now().difference(started) > const Duration(milliseconds: 900)) {
      return;
    }
    AdScheduler.instance.onGenuineTap();
  }

  void _onCancel(PointerCancelEvent event) {
    if (event.pointer == _pointer) _resetPointer();
  }

  void _resetPointer() {
    _pointer = null;
    _downPos = null;
    _downAt = null;
    _moved = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onDown,
      onPointerMove: _onMove,
      onPointerUp: _onUp,
      onPointerCancel: _onCancel,
      child: widget.child,
    );
  }
}
