import 'package:flutter/material.dart';
import 'package:note_repository/constants/design/app_curves.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/models/setting_notifier.dart';

class MultipleSwitch extends StatefulWidget {
  final SettingNotifier setting;

  const MultipleSwitch(this.setting, {super.key});

  @override
  State<MultipleSwitch> createState() => _MultipleSwitchState();
}

class _MultipleSwitchState extends State<MultipleSwitch> {
  static const double _edgeLength = AppSizes.m;
  static const double _thickness = AppSizes.borderWidthS;
  static const double _iconSize = AppSizes.iconM;

  static const Curve _curve = AppCurves.slide;
  static const Duration _slideAnimationDuration = AppDurations.m;

  late int _index = widget.setting.value.index;
  late final _optionLength = widget.setting.setting.options.length;
  //late NewSetting _setting;

  void _listener() {
    if (!mounted) return;
    setState(() {
      _index = widget.setting.value.index;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.setting.addListener(_listener);
  }

  @override
  void dispose() {
    widget.setting.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double selectorEdgeLength = (_edgeLength + _iconSize) / 2;
    return Stack(
      children: [
        _buildSwitchBox(),
        _buildSelectionMark(selectorEdgeLength),
        _buildOptionButtons(),
      ],
    );
  }

  Widget _buildSwitchBox() {
    return Container(
      height: _edgeLength + _thickness * 2,
      width: _edgeLength * _optionLength + _thickness * (_optionLength + 1),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(
          width: _thickness,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _optionLength - 1,
          (index) => Container(
            height: _iconSize,
            width: _thickness,
            color: const Color(0xFFC0C0C0),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionMark(double selectorEdgeLength) {
    return AnimatedPositioned(
      duration: _slideAnimationDuration,
      curve: _curve,
      top: (_edgeLength - selectorEdgeLength) / 2 + _thickness,
      left:
          (_edgeLength - selectorEdgeLength) / 2 + (_thickness + _edgeLength) * _index + _thickness,
      onEnd: () => widget.setting.value = widget.setting.setting.options[_index].value,
      child: Container(
        height: selectorEdgeLength,
        width: selectorEdgeLength,
        decoration: BoxDecoration(
          color: const Color(0xFF00FF0A).withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(
            color: const Color(0xFF00FF0A),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButtons() {
    return Positioned(
      top: _thickness,
      left: _thickness,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          _optionLength,
          (index) => Container(
            margin: EdgeInsets.only(left: index != 0 ? _thickness : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _index = index;
                });
              },
              child: Container(
                height: _edgeLength,
                width: _edgeLength,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
                child: Icon(
                  widget.setting.setting.options[index].icon,
                  size: _iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
