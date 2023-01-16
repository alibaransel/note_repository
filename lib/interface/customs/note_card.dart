import 'package:flutter/material.dart';
import 'package:note_repository/constants/app_key_maps.dart';
import 'package:note_repository/constants/app_keys.dart';
import 'package:note_repository/constants/design/app_colors.dart';
import 'package:note_repository/constants/design/app_icons.dart';
import 'package:note_repository/constants/design/app_sizes.dart';
import 'package:note_repository/models/note.dart';
import 'package:note_repository/services/navigation_service.dart';
import 'package:note_repository/services/path_service.dart';

class NoteCard extends StatelessWidget {
  final NoteInfo noteInfo;
  final String groupPath;

  const NoteCard({
    super.key,
    required this.noteInfo,
    required this.groupPath,
  });

  @override
  Widget build(BuildContext context) {
    final String notePath = PathService().note(groupPath: groupPath, noteInfo: noteInfo);

    return GestureDetector(
      onTap: () => NavigationService().show(NavigationRoute.note(notePath)),
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: '${AppKeys.noteBackgroundTag}-$notePath',
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.groupRed,
                      AppColors.groupPurple,
                    ],
                  ),
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
                      tag: '${AppKeys.noteTitleTag}-$notePath',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Row(
                          children: [
                            Icon(
                              AppKeyMaps.noteIcon[noteInfo.type],
                              size: AppSizes.iconL,
                            ),
                            const SizedBox(width: AppSizes.spacingM),
                            Expanded(
                              child: Text(
                                noteInfo.name,
                                softWrap: false,
                                overflow: TextOverflow.fade,
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
