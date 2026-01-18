import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDelay;
  final Duration startDelay;
  final bool showCursor;
  final Duration cursorBlink;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 60),
    this.startDelay = const Duration(milliseconds: 150),
    this.showCursor = true,
    this.cursorBlink = const Duration(milliseconds: 500),
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _charCount;
  AnimationController? _cursorController;
  Animation<double>? _cursorOpacity;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    final textChanged = oldWidget.text != widget.text ||
        oldWidget.charDelay != widget.charDelay ||
        oldWidget.startDelay != widget.startDelay;

    if (textChanged) {
      _startTimer?.cancel();
      _controller
        ..stop()
        ..reset();
      _configureTyping();
      _startTyping();
    }

    if (oldWidget.showCursor != widget.showCursor ||
        oldWidget.cursorBlink != widget.cursorBlink) {
      _cursorController?.dispose();
      _cursorController = null;
      _cursorOpacity = null;
      if (widget.showCursor) {
        _initCursor();
      }
    }
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    _cursorController?.dispose();
    super.dispose();
  }

  void _initControllers() {
    final duration = _typingDuration();
    _controller = AnimationController(vsync: this, duration: duration);
    _configureTyping();
    if (widget.showCursor) {
      _initCursor();
    }
  }

  void _configureTyping() {
    final duration = _typingDuration();
    _controller.duration = duration;
    _charCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  Duration _typingDuration() {
    if (widget.text.isEmpty) {
      return const Duration(milliseconds: 1);
    }
    final ms = widget.text.length * widget.charDelay.inMilliseconds;
    return Duration(milliseconds: ms.clamp(1, 600000));
  }

  void _startTyping() {
    if (widget.text.isEmpty) {
      return;
    }
    if (widget.startDelay > Duration.zero) {
      _startTimer = Timer(widget.startDelay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    } else {
      _controller.forward();
    }
  }

  void _initCursor() {
    _cursorController = AnimationController(
      vsync: this,
      duration: widget.cursorBlink,
    )..repeat(reverse: true);
    _cursorOpacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _cursorController!, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;

    if (widget.text.isEmpty) {
      return Text(
        '',
        style: style,
        textAlign: widget.textAlign,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final count = _charCount.value.clamp(0, widget.text.length);
        final visible = widget.text.substring(0, count);
        final showCursor =
            widget.showCursor && count < widget.text.length;
        final cursorOpacity = _cursorOpacity?.value ?? 1.0;

        return RichText(
          textAlign: widget.textAlign ?? TextAlign.start,
          maxLines: widget.maxLines,
          overflow: widget.overflow ?? TextOverflow.clip,
          text: TextSpan(
            style: style,
            children: [
              TextSpan(text: visible),
              if (showCursor)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: Opacity(
                    opacity: cursorOpacity,
                    child: Text('|', style: style),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
