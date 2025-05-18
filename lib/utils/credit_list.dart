import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/ui/crew_dialog.dart';
import 'package:flutter/material.dart';

/// Utility class for handling crew member lists with text wrapping
class CrewListUtils {
  static Widget buildCreditLists(
    BuildContext context,
    Film film,
    Map<String, bool> expandedRoles,
    int collapsedMaxRows,
    Function(String) onFilmSelected,
    Function(String) toggleExpanded,
  ) {
    // Extract unique roles
    final roles = film.crewMembers
        .where((m) => m.role.isNotEmpty)
        .map((m) => m.role.toLowerCase())
        .toSet();

    // Create display names with proper capitalization
    final displayNames = {
      for (var role in roles)
        role: role
            .replaceAll('-', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ')
    };

    // Sort roles by priority then alphabetically
    final priority = ['actor', 'director', 'writer', 'producer'];
    final sortedRoles = roles.toList()
      ..sort((a, b) {
        final aIndex = priority.indexOf(a);
        final bIndex = priority.indexOf(b);
        final aPriority = aIndex < 0 ? priority.length : aIndex;
        final bPriority = bIndex < 0 ? priority.length : bIndex;
        return aPriority != bPriority ? aPriority - bPriority : a.compareTo(b);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedRoles.map((role) {
        final crewList = film.crewMembers
            .where((m) => m.role.toLowerCase() == role)
            .toList()
          ..sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));
        final isExpanded = expandedRoles[role] ?? false;
        return _buildRoleSection(
          context,
          role,
          displayNames[role]!,
          crewList,
          isExpanded,
          collapsedMaxRows,
          onFilmSelected,
          () => toggleExpanded(role),
        );
      }).toList(),
    );
  }

  // Extracted method to build individual role sections with unified calculation
  static Widget _buildRoleSection(
    BuildContext context,
    String role,
    String title,
    List<CrewMember> crewList,
    bool isExpanded,
    int collapsedMaxRows,
    Function(String) onFilmSelected,
    VoidCallback toggleExpanded,
  ) {
    final maxRows = isExpanded ? 150 : collapsedMaxRows;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          // Prepare text style and fixed widths
          final textStyle = Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: 12);
          final startText = '';
          final endText = '...';
          final startW = (startText.isNotEmpty)
              ? _calculateTextWidth(TextSpan(text: startText, style: textStyle), context) + 4
              : 0.0;
          final endW = _calculateTextWidth(TextSpan(text: endText, style: textStyle), context) + 4;

          // Calculate how many fit
          final visibleCount = _calculateVisibleCrewCount(
            crewList,
            textStyle,
            context,
            constraints.maxWidth,
            collapsedMaxRows,
            startW,
            endW,
          );
          final showMoreButton = visibleCount < crewList.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (showMoreButton)
                    GestureDetector(
                      onTap: toggleExpanded,
                      child: Text(
                        isExpanded ? '▲' : '▼',
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: buildCrewList(
                  crewMembers: crewList,
                  role: role,
                  startText: startText,
                  context: context,
                  maxWidth: constraints.maxWidth,
                  maxRows: maxRows,
                  onCrewTapped: (member, role) => showCrewPopup(
                      context, member, role, onFilmSelected),
                  endText: endText,
                  onMoreTapped: toggleExpanded,
                  textStyle: textStyle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper to count how many crew members would be visible
  static int _calculateVisibleCrewCount(
    List<CrewMember> crew,
    TextStyle? style,
    BuildContext context,
    double maxWidth,
    int maxRows,
    double startW,
    double endW,
  ) {
    int count = 0;
    int rows = 0;
    double rowW = startW;

    for (int i = 0; i < crew.length; i++) {
      final isLast = i == crew.length - 1;
      final txt = isLast ? crew[i].name : '${crew[i].name},';
      final w = _calculateTextWidth(TextSpan(text: txt, style: style), context) + 4;

      if (rowW + w > maxWidth) {
        rows++;
        rowW = 0;
        if (rows >= maxRows) break;
      }

      final isLastRow = rows == maxRows - 1;
      if (isLastRow && i < crew.length - 1 && rowW + w + endW > maxWidth) {
        break;
      }

      count++;
      rowW += w;
    }

    return count;
  }

  // Kept buildCrewList method signature identical for compatibility
  static Widget buildCrewList({
    required List<CrewMember> crewMembers,
    required String role,
    String? startText,
    required BuildContext context,
    required double maxWidth,
    required int maxRows,
    required Function(CrewMember, String) onCrewTapped,
    String endText = '…',
    VoidCallback? onMoreTapped,
    TextStyle? textStyle,
    TextAlign? textAlign = TextAlign.left,
  }) {
    final crew = crewMembers
        .where((m) => m.role.toLowerCase() == role.toLowerCase())
        .toList()
      ..sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));

    const double rowHeight = 18.0;
    final effectiveStyle = textStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12);

    return SizedBox(
      width: maxWidth,
      child: LayoutBuilder(builder: (context, constraints) {
        final startW = (startText?.isNotEmpty ?? false)
            ? _calculateTextWidth(TextSpan(text: startText, style: effectiveStyle), context) + 4
            : 0.0;
        final endW = _calculateTextWidth(TextSpan(text: endText, style: effectiveStyle), context) + 4;

        final visibleCrew = _calculateVisibleCrew(
          crew,
          effectiveStyle,
          context,
          constraints.maxWidth,
          maxRows,
          startW,
          endW,
        );

        final widgets = <Widget>[];
        if (startText != null && startText.isNotEmpty) {
          widgets.add(Text(
            startText,
            style: effectiveStyle,
            textAlign: textAlign,
          ));
        }

        for (int i = 0; i < visibleCrew.length; i++) {
          final member = visibleCrew[i];
          final isLastVisible = i == visibleCrew.length - 1 &&
              visibleCrew.length == crew.length;
          final txt = isLastVisible ? member.name : '${member.name},';

          widgets.add(
            GestureDetector(
              onTap: () => onCrewTapped(member, role),
              child: Text(
                txt,
                style: effectiveStyle
                    ?.copyWith(decoration: TextDecoration.underline),
                textAlign: textAlign,
              ),
            ),
          );
        }

        if (visibleCrew.length < crew.length) {
          widgets.add(
            GestureDetector(
              onTap: onMoreTapped,
              child: Text(
                endText,
                style: effectiveStyle?.copyWith(
                  color: Colors.grey,
                  decoration: TextDecoration.underline,
                ),
                textAlign: textAlign,
              ),
            ),
          );
        }

        final rowCount = _calculateRowCount(
          visibleCrew,
          effectiveStyle,
          context,
          constraints.maxWidth,
          startW,
        );

        return SizedBox(
          height: rowCount.clamp(1, maxRows) * rowHeight,
          child: Wrap(
            alignment: textAlign == TextAlign.center
                ? WrapAlignment.center
                : WrapAlignment.start,
            spacing: 4,
            runSpacing: 2,
            children: widgets,
          ),
        );
      }),
    );
  }

  // Helper method to calculate visible crew members
  static List<CrewMember> _calculateVisibleCrew(
    List<CrewMember> crew,
    TextStyle? style,
    BuildContext context,
    double maxWidth,
    int maxRows,
    double startW,
    double endW,
  ) {
    final visibleCount = _calculateVisibleCrewCount(
      crew, style, context, maxWidth, maxRows, startW, endW);
    return crew.take(visibleCount).toList();
  }

  // Calculate how many rows the text will occupy
  static int _calculateRowCount(
    List<CrewMember> crew,
    TextStyle? style,
    BuildContext context,
    double maxWidth,
    double startW,
  ) {
    if (crew.isEmpty) return 1;
    int rows = 0;
    double rowW = startW;
    for (int i = 0; i < crew.length; i++) {
      final isLast = i == crew.length - 1;
      final txt = isLast ? crew[i].name : '${crew[i].name},';
      final w = _calculateTextWidth(TextSpan(text: txt, style: style), context) + 4;
      if (rowW + w > maxWidth) {
        rows++;
        rowW = w;
      } else {
        rowW += w;
      }
    }
    return rows + 1;
  }

  // Original text width helper
  static double _calculateTextWidth(TextSpan text, BuildContext context) {
    final tp = TextPainter(
      text: text,
      textDirection: Directionality.of(context),
    )..layout();
    return tp.width;
  }
}
