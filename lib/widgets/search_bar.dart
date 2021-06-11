import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        top: 5,
        right: 10,
        bottom: 5,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => print(_searchController.text),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(
                5.0,
              ),
            ),
            borderSide: BorderSide(
              width: 0,
              //color: Color(0xFFfb3132),
              color: Colors.purple,
              style: BorderStyle.none,
            ),
          ),
          filled: true,
          prefixIcon: Icon(
            Icons.search,
            color: Color(0xFFfb3132),
          ),
          fillColor: Color(0xFFFAFAFA),
          hintStyle: new TextStyle(color: Color(0xFFd0cece), fontSize: 18),
          hintText: "Where would you like to buy?",
        ),
      ),
    );
  }
}
