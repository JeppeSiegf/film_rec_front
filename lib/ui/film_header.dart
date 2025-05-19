import 'package:film_rec_front/data/models.dart';
import 'package:film_rec_front/theme/theme_manager.dart';
import 'package:film_rec_front/ui/crew_dialog.dart';
import 'package:film_rec_front/ui/film_dialog.dart';
import 'package:film_rec_front/utils/credit_list.dart';
import 'package:film_rec_front/utils/poster_diplay.dart';
import 'package:film_rec_front/utils/runtime_converter.dart';
import 'package:film_rec_front/utils/tag_list.dart';
import 'package:film_rec_front/utils/title_display.dart';
import 'package:flutter/material.dart';

class MovieDetailsWidget extends StatelessWidget {
  final Film film;
  final bool isImageMoved;
  final VoidCallback onToggle;
  final Function(String) onFilmSelected;

  const MovieDetailsWidget({
    required this.film,
    required this.isImageMoved,
    required this.onToggle,
    required this.onFilmSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 350),
      crossFadeState: isImageMoved 
          ? CrossFadeState.showSecond 
          : CrossFadeState.showFirst,
      firstChild: _buildVerticalLayout(context),
      secondChild: _buildHorizontalLayout(context),
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      children: [
        MovieTextUtils.buildMovieTitle(
          film: film,
          context: context,
          includeYear: true,
          textAlign: TextAlign.start,
          animateLocaleChanges: true,
          maxLines: 2,
        ),
        const SizedBox(height: 15),
        MovieImageUtils.buildMoviePoster(
          imageUrl: film.largeImageRef,
          size: PosterSize.large,
        ),
      ],
    );
  }
  Widget _buildHorizontalLayout(BuildContext context) {
    const maxColumnWidth = 350.0;
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: MovieImageUtils.buildMoviePoster(
            imageUrl: film.largeImageRef,
            size: PosterSize.small,
          ),
        ),
        // Ensure the text starts top-left and doesn't get centered
        Expanded(
          child: Column(
             
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MovieTextUtils.buildMovieTitle(
                film: film,
                context: context,
                includeYear: true,
                textAlign: TextAlign.start,
                animateLocaleChanges: true,
                maxLines: 2,
              ),
              CrewListUtils.buildCrewList(
                context: context,
                crewMembers: film.crewMembers,
                startText: 'dir.',
                role: 'director',
                maxRows: 1,
                maxWidth: maxColumnWidth,
                onCrewTapped: (member, role) => showCrewPopup(context, member, role, onFilmSelected),
                onMoreTapped: () => showFilmPopup(context, film, onFilmSelected),
              ),
            
              const SizedBox(height: 6),
              TagListUtils.buildTagList(context:context, 
                                        tags:film.genres, 
                                        ),
              const SizedBox(height: 6),
               CrewListUtils.buildCrewList(
                context: context,
                crewMembers: film.crewMembers,
                startText: 'Starring:',
                role: 'actor',
                maxRows: 3,
                maxWidth: maxColumnWidth,
                onCrewTapped: (member, role) => showCrewPopup(context, member, role, onFilmSelected),
                onMoreTapped: () => showFilmPopup(context, film, onFilmSelected),

              ),
              const SizedBox(height:6),
              RunTimeConverter.buildRuntimeText(
                context: context,
                film.runTime,
                expandedText: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
