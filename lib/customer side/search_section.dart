import 'package:flutter/material.dart';

class SearchSection extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const SearchSection({
    Key? key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: 'Find Services'),
        SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: SearchField()),
            SizedBox(width: 12),
            FilterButton(
              filters: filters,
              onFilterChanged: onFilterChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3748),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Find salons, clinics, auto-shops...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final List<String> filters;
  final ValueChanged<String> onFilterChanged;

  const FilterButton({
    Key? key,
    required this.filters,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF667eea),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.tune, color: Colors.white),
        onSelected: onFilterChanged,
        itemBuilder: (context) => filters
            .map(
              (filter) => PopupMenuItem(value: filter, child: Text(filter)),
            )
            .toList(),
      ),
    );
  }
}