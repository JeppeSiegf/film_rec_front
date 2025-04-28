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
    Function(String) toggleExpanded
  ) {
    final roles = <String>{};
    for (var m in film.crewMembers) {
      if (m.role.isNotEmpty) roles.add(m.role.toLowerCase());
    }
    
    final displayNames = <String, String>{};
    for (var r in roles) {
      displayNames[r] = r
          .replaceAll('-', ' ')
          .split(' ')
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
    }
    
    final priority = ['actor', 'director', 'writer', 'producer'];
    final sorted = roles.toList()
      ..sort((a, b) {
        final ai = priority.indexOf(a);
        final bi = priority.indexOf(b);
        final aP = ai < 0 ? priority.length : ai;
        final bP = bi < 0 ? priority.length : bi;
        return aP != bP ? aP - bP : a.compareTo(b);
      });
      
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sorted.map((role) {
        final title = displayNames[role]!;
        final crewList = film.crewMembers
            .where((m) => m.role.toLowerCase() == role)
            .toList()
          ..sort((a, b) => (a.rank ?? 0).compareTo(b.rank ?? 0));
        
        final isExpanded = expandedRoles[role] ?? false;
        final displayRows = isExpanded ? 150 : collapsedMaxRows; // 150 is effectively unlimited
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
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
                  Builder(
                    builder: (context) {
                      // Check if this role has more crew members than can fit in the default view
                      bool showMoreButton = false;
                      
                      // Calculate if there are more crew members than what fits in collapsed mode
                      final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12);
                      double rowWidth = 0;
                      int currentRow = 0;
                      int visibleCount = 0;
                      
                      for (int i = 0; i < crewList.length; i++) {
                        final member = crewList[i];
                        final isLast = i == crewList.length - 1;
                        final text = isLast ? member.name : '${member.name},';
                        
                        // Approximate width for this member name
                        final textPainter = TextPainter(
                          text: TextSpan(text: text, style: textStyle),
                          textDirection: TextDirection.ltr,
                        )..layout();
                        final memberWidth = textPainter.width + 4;
                        
                        // Check if this would wrap to next line
                        if (rowWidth + memberWidth > MediaQuery.of(context).size.width - 40) { // approximate padding
                          currentRow++;
                          rowWidth = memberWidth;
                        } else {
                          rowWidth += memberWidth;
                        }
                        
                        visibleCount++;
                        
                        if (currentRow >= collapsedMaxRows) {
                          if (i < crewList.length - 1) {
                            showMoreButton = true;
                          }
                          break;
                        }
                      }
                      
                      return showMoreButton
                        ? GestureDetector(
                            onTap: () => toggleExpanded(role),
                            child: Text(
                              isExpanded ? '▲' : '▼',
                              style: TextStyle(
                                fontSize: 12,

                              ),
                            ),
                          )
                        : SizedBox.shrink();
                    }
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return buildCrewList(
                      crewMembers: film.crewMembers,
                      role: role,
                      startText: "",
                      context: context,
                      maxWidth: constraints.maxWidth,
                      maxRows: displayRows,
                      onCrewTapped: (member, role) => showCrewPopup(
                        context, member, role, onFilmSelected),
                      endText: "...",
                      onMoreTapped: () => toggleExpanded(role), // Connect ellipsis click to toggle
                    );
                  }
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
 
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
  TextAlign? textAlign = TextAlign.left, // <-- tilføjet
}) {
  final crew = crewMembers
      .where((m) => m.role.toLowerCase() == role.toLowerCase())
      .toList()
    ..sort((a, b) => a.rank!.compareTo(b.rank!));

  const double rowHeight = 18.0;
  final defaultStyle = Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12);
  final effectiveStyle = textStyle ?? defaultStyle;

  return SizedBox(
    width: maxWidth,
    child: LayoutBuilder(builder: (context, constraints) {
      final startW = (startText?.isNotEmpty ?? false)
          ? _calculateTextWidth(TextSpan(text: startText, style: effectiveStyle), context) + 4
          : 0.0;
      final endW = _calculateTextWidth(TextSpan(text: endText, style: effectiveStyle), context) + 4;

      List<CrewMember> visible = [];
      int rows = 0;
      double rowW = startW;

      for (int i = 0; i < crew.length; i++) {
        final isLast = i == crew.length - 1;
        final txt = isLast ? crew[i].name : '${crew[i].name},';
        final w = _calculateTextWidth(TextSpan(text: txt, style: effectiveStyle), context) + 4;

        if (rowW + w > constraints.maxWidth) {
          rows++;
          rowW = 0;
          if (rows >= maxRows) break;
        }

        final isLastRow = rows == maxRows - 1;
        if (isLastRow && i < crew.length - 1 && rowW + w + endW > constraints.maxWidth) {
          break;
        }

        visible.add(crew[i]);
        rowW += w;
      }

      final widgets = <Widget>[];
      if (startText != null && startText.isNotEmpty) {
        widgets.add(Text(
          startText,
          style: effectiveStyle,
          textAlign: textAlign, // <-- styres af parameter
        ));
      }

      for (int i = 0; i < visible.length; i++) {
        final member = visible[i];
        final isLastVisible = i == visible.length - 1;
        final txt = isLastVisible ? member.name : '${member.name},';
        widgets.add(
          GestureDetector(
            onTap: () => onCrewTapped(member, role),
            child: Text(
              txt,
              style: effectiveStyle?.copyWith(decoration: TextDecoration.underline),
              textAlign: textAlign, // <-- styres af parameter
            ),
          ),
        );
      }

      if (visible.length < crew.length) {
        widgets.add(
          GestureDetector(
            onTap: onMoreTapped,
            child: Text(
              endText,
              style: effectiveStyle?.copyWith(
                color: Colors.grey,
                decoration: TextDecoration.underline,
              ),
              textAlign: textAlign, // <-- styres af parameter
            ),
          ),
        );
      }

      return SizedBox(
        height: (rows + 1).clamp(1, maxRows) * rowHeight,
        child: Wrap(
          alignment: textAlign == TextAlign.center
              ? WrapAlignment.center
              : WrapAlignment.start, // <-- også styret af parameter
          spacing: 4,
          runSpacing: 2,
          children: widgets,
        ),
      );
    }),
  );
}



static double _calculateTextWidth(TextSpan text, BuildContext context) {
  final tp = TextPainter(
    text: text,
    textDirection: Directionality.of(context),
  )..layout();
  return tp.width;
}
}