// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/news_service.dart';
import 'news_detail_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const NewsListWidget(),
    const ExplorePage(),
    const BookmarkPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        enableFeedback: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks_rounded),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_rounded),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class NewsListWidget extends StatefulWidget {
  const NewsListWidget({Key? key}) : super(key: key);

  @override
  _NewsListWidgetState createState() => _NewsListWidgetState();
}

class _NewsListWidgetState extends State<NewsListWidget> {
  late Future<List<dynamic>> _newsFuture;
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _filteredNews = [];

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService().fetchNews();
    _newsFuture.then((news) {
      setState(() {
        _filteredNews = news;
      });
    });
  }

  void _searchNews(String query) {
    setState(() {
      _newsFuture = NewsService().searchNews(query);
      _newsFuture.then((news) {
        setState(() {
          _filteredNews = news;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16, 10),
            child: TextField(
              controller: _searchController,
              onSubmitted: _searchNews,
              enableSuggestions: true,
              style: GoogleFonts.nunito(textStyle: const TextStyle(fontWeight: FontWeight.w700)),
              decoration: const InputDecoration(
                
                hintText: 'Search news...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load news: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No news available'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredNews.length,
                    itemBuilder: (context, index) {
                      final article = _filteredNews[index];
                      return NewsCard(article: article);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final dynamic article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailPage(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article['urlToImage'] != null &&
                  article['urlToImage'].startsWith('http'))
                CachedNetworkImage(
                  imageUrl: article['urlToImage'],
                  height: 90,
                  width: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 100,
                    width: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    // Check if the error is NetworkImageLoadException and status code is 500
                    if (error is NetworkImageLoadException && error.statusCode == 500) {
                      return Container(
                        height: 90,
                        width: 90,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.newspaper_rounded,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    } else {
                      return Container(
                        height: 90,
                        width: 90,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    }
                  },
                )
              else
                Container(
                  height: 90,
                  width: 90,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.newspaper_rounded,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article['title'] ?? 'No title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(textStyle :const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      article['source']['name'] ?? 'No Source',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunitoSans(textStyle :const TextStyle(fontSize: 12.5,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 95, 95, 95)),),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
      ),
      body: const Center(child: Text('Explore Page')),
    );
  }
}

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark'),
      ),
      body: const Center(child: Text('Bookmark Page')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(child: Text('Profile Page')),
    );
  }
}
