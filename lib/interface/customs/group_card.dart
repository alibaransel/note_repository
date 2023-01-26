import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/app_navigation_routes.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/interface/common/common_text.dart';
import 'package:note_repository/models/group.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/path_service.dart';

class GroupCard extends StatelessWidget {
  final GroupInfo groupInfo;
  final String parentGroupPath;

  const GroupCard({
    super.key,
    required this.groupInfo,
    required this.parentGroupPath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavigationService().show(
          AppNavigationRoutes.group(
            groupPath: PathService().group(
              parentGroupPath: parentGroupPath,
              groupInfo: groupInfo,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: '${AppKeys.groupBackgroundTag}-$parentGroupPath-${groupInfo.name}',
              child: Container(
                decoration: BoxDecoration(
                  color: groupInfo.color,
                  borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.spacingM),
              child: Row(
                children: [
                  Expanded(
                    child: Hero(
                      tag: '${AppKeys.groupTitleTag}-$parentGroupPath-${groupInfo.name}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          children: [
                            const Icon(
                              AppIcons.folder,
                              size: AppSizes.iconL,
                            ),
                            const SizedBox(width: AppSizes.spacingM),
                            Expanded(
                              child: CommonText(
                                groupInfo.name,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  const Icon(AppIcons.arrowForward)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
