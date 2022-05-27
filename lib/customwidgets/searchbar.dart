import 'package:flutter/material.dart';

class SearchBar {
  var searchController = TextEditingController();
  Widget build({required VoidCallback searchQuery, required String defaultTitle}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
            Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                      hintText: 'Search',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: (){
                          //TODO: search the query
                          searchQuery();
                        },
                      )
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.black38))
            ),
            child: Text(searchController.text.isNotEmpty ? '${searchController.text}' : '$defaultTitle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color:  Colors.black54
              ),
            ),
          ),
          SizedBox(height: 5,)
        ]
      ),
    );
  }
}