import 'package:flutter/material.dart';

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;

  StarRating({this.starCount = 5, this.rating = .0, required this.onRatingChanged});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = const Icon(
        Icons.star_border,
        color: Colors.amber,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = const Icon(
        Icons.star_half,
        color: Colors.blue,
      );
    } else {
      icon = const Icon(
        Icons.star,
        color: Colors.amber,
      );
    }
    return InkResponse(
      onTap: onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        starCount, (index) => buildStar(context, index)
      )
    );
  }
}