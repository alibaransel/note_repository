import 'dart:async';

import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_id_code_maps.dart';
import 'package:note_repository/constants/app_id_codes.dart';
import 'package:note_repository/constants/app_strings.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_curves.dart';
import 'package:note_repository/constants/design/app_durations.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_physics.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_text_field.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/services/item_service.dart';
import 'package:note_repository/services/navigation_service.dart';

class CreateGroupView extends StatefulWidget {
  const CreateGroupView({super.key});

  @override
  State<CreateGroupView> createState() => _CreateGroupViewState();
}

class _CreateGroupViewState extends State<CreateGroupView> {
  static const Curve _slideAnimationCurve = AppCurves.slide;
  static const Duration _slideAnimationDuration = AppDurations.m;
  static const Curve _scaleAnimationCurve = AppCurves.scale;
  static const Duration _scaleAnimationDuration = AppDurations.m;

  final List<dynamic> _colorList = //TODO: Is static keyword usage correct?
      AppIdCodeMaps.codeTypeMap[AppIdCodes.color]!.values.toList();

  final TextEditingController _groupNameTextController = TextEditingController();

  final PageController _colorPageController = PageController(
    viewportFraction: 0.3,
  );

  int _currentColorIndex = 0;
  String _response = '';
  String _alertText = '';

  Future<void> tryCreateGroup() async {
    if (_groupNameTextController.text.isEmpty) {
      setState(() {
        _alertText = 'Please enter name'; //TODO
      });
      return;
    }
    _response = await ItemService.lastItemService.tryCreateGroup(
      GroupInfo(
        name: _groupNameTextController.text,
        dateTime: DateTime.now(),
        color: _colorList[_currentColorIndex],
      ),
    );
    if (_response == 'done') {
      const NavigationService().hide();
      return;
    }
    setState(() {
      _alertText = _response; //TODO
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: AppSizes.spacingM,
        right: AppSizes.spacingM,
        bottom: AppSizes.spacingM + MediaQuery.of(context).viewInsets.bottom,
      ),
      padding: const EdgeInsets.all(AppSizes.spacingL),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: AppSizes.shadowRadius,
            blurRadius: AppSizes.shadowRadius,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(),
          const SizedBox(height: AppSizes.spacingM),
          _buildAlertBox(),
          _buildTextField(),
          const SizedBox(height: AppSizes.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildColorInput(),
              ),
              const SizedBox(width: AppSizes.spacingM),
              _buildCreateButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      AppStrings.createGroup,
      style: TextStyle(fontSize: 20),
    );
  }

  Widget _buildAlertBox() {
    return AnimatedSwitcher(
      duration: AppDurations.m,
      child: _alertText.isEmpty
          ? null
          : Container(
              margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacingM),
              height: AppSizes.s,
              decoration: const ShapeDecoration(
                color: AppColors.secondaryColor,
                shape: StadiumBorder(),
              ),
              child: Row(
                children: [
                  const Icon(
                    AppIcons.error,
                    size: AppSizes.iconS,
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Text(_alertText),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField() {
    return CommonTextField(
      controller: _groupNameTextController,
      autoFocus: true,
      centerText: true,
      hintText: AppStrings.groupNameHint,
      onChanged: (text) {
        if (text.isNotEmpty && _alertText.isNotEmpty) {
          setState(() {
            _alertText = '';
          });
        }
      },
      onEditingComplete: tryCreateGroup,
    );
  }

  Widget _buildColorInput() {
    return Container(
      padding: const EdgeInsets.only(left: AppSizes.spacingL),
      decoration: const ShapeDecoration(
        color: Colors.black54,
        shape: StadiumBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.color,
            style: TextStyle(fontSize: 20),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.inputHeight / 2),
            child: Container(
              height: AppSizes.inputHeight,
              width: 150, //TODO: fix
              color: Colors.black,
              child: PageView.builder(
                itemCount: _colorList.length,
                physics: AppPhysics.main,
                controller: _colorPageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentColorIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: GestureDetector(
                      onTap: () {
                        _colorPageController.animateToPage(
                          index,
                          duration: _slideAnimationDuration,
                          curve: _slideAnimationCurve,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: AppSizes.spacingXS),
                        padding: const EdgeInsets.all(AppSizes.spacingS),
                        height: AppSizes.xS,
                        width: AppSizes.xS,
                        decoration: BoxDecoration(
                          color: _colorList[index],
                          shape: BoxShape.circle,
                        ),
                        child: AnimatedScale(
                          duration: _scaleAnimationDuration,
                          curve: _scaleAnimationCurve,
                          scale: index == _currentColorIndex ? 1 : 0,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return GestureDetector(
      onTap: tryCreateGroup,
      child: Container(
        height: AppSizes.inputHeight,
        width: AppSizes.xXL,
        alignment: Alignment.center,
        decoration: const ShapeDecoration(
          color: AppColors.secondaryColor,
          shape: StadiumBorder(),
        ),
        child: const Text(AppStrings.create),
      ),
    );
  }
}
