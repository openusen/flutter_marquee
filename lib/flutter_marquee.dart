library flutter_marquee;

import 'package:flutter/material.dart';

/// A Calculator.
class Marquee extends StatefulWidget {
  Marquee(
      {Key key,
      @required this.str,
      @required this.containerWidth,
      this.textStyle = const TextStyle(),
      this.strutStyle = const StrutStyle(),
      this.baseMilliseconds = 4000})
      : super(key: key);

  final String str;
  final double containerWidth;
  final TextStyle textStyle;
  final double baseMilliseconds;
  final StrutStyle strutStyle;

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  ScrollController _scrollController;
  VoidCallback listener;
  bool disposeFlag = false;

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
        text: TextSpan(text: text, style: style),
        maxLines: 1,
        textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
    );
    final Size txtSize = _textSize(widget.str, widget.textStyle);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
          milliseconds:
          (txtSize.width / widget.containerWidth * widget.baseMilliseconds)
              .ceil()),
    );
    _animationController.drive(
      CurveTween(curve: Curves.easeOutQuint),
    );

    WidgetsBinding.instance
        .addPostFrameCallback((_){
      listener = () async {
        if (_animationController.isCompleted) {
          _scrollController.jumpTo(0.0);
          await Future<dynamic>.delayed(const Duration(seconds: 1));
          if (!disposeFlag) {
            _animationController.reset();
            _animationController.forward();
          }
        } else if (_scrollController.offset <
            txtSize.width * _animationController.value &&
            _scrollController.offset < txtSize.width) {
          _scrollController.animateTo(txtSize.width * _animationController.value,
              duration: const Duration(milliseconds: 100), curve: Curves.easeOutQuint);
        }
      };
      _animationController.addListener(listener);
      _animationController.forward();
    });
  }

  @override
  void didUpdateWidget(Marquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.str != widget.str) {
      final Size txtSize = _textSize(widget.str, widget.textStyle);
      _animationController.reset();
      _animationController.removeListener(listener);
      listener = () async {
        if (_animationController.isCompleted) {
          _scrollController.jumpTo(0.0);
          await Future.delayed(new Duration(seconds: 1));
          if (!disposeFlag) {
            _animationController.reset();
            _animationController.forward();
          }
        } else if (_scrollController.offset <
            txtSize.width * _animationController.value &&
            _scrollController.offset < txtSize.width) {
          _scrollController.animateTo(txtSize.width * _animationController.value,
              duration: Duration(milliseconds: 100), curve: Curves.easeOutQuint);
        }
      };
      _animationController.addListener(listener);
      _animationController.duration = Duration(
          milliseconds:
          (txtSize.width / widget.containerWidth * widget.baseMilliseconds)
              .ceil());
      _scrollController.jumpTo(0.0);
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    disposeFlag = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowGlow();
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Text(
          widget.str,
          style: widget.textStyle,
          strutStyle: widget.strutStyle,
        ),
      ),
    );
  }
}
