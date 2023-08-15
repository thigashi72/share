// インポートは増えてます
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

// const endpoint = 'https://g0d4r3ki1s.microcms.io/api/v1/news/';
// const apiKey = 'X77GJpqOSimIXgXf0RXAoa5FL5W0Pzr2Qs1B';

const endpoint = 'https://1dsrztk2r7.microcms.io/api/v1/test/';
const apiKey = 'WuctDl2tY216PaqGo9SGSJCngg5IDofxTHsK';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: MyAppList()
    );
  }
}

class MyAppList extends StatefulWidget {
  @override
  _MyAppListState createState() => _MyAppListState();
}


class _MyAppListState extends State<MyAppList> {
  final _listItems = <ListItem>[];
  // final List _listItems = []; 

  void _loadListItem() async {
    // Urlの指定方法は変更済み
    final result = await http.get(Uri.parse(endpoint),
    // final result = await http.get(Uri.parse('$endpoint?fields=id,publishedAt,title,eyecatching'),
        headers: {
          "X-MICROCMS-API-KEY": apiKey
        });

    //これで表示するデータの中身が確認できます
    print(result.body);

    List contents = json.decode(result.body)['contents'];
    // print(contents);
    _listItems.clear();
    _listItems.addAll(contents.map((content) => ListItem.fromJSON(content)));



    // print("いいい");
    // print(_listItems[0].id);

    
  }

  @override
  void didUpdateWidget(MyAppList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadListItem();
  }

  @override
  void initState() {
    super.initState();
    _loadListItem();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記事一覧'),
      ),
      body: ListView(
        children: _listItems.map((listItem) =>
          Card(
            child: ListTile(
              leading: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: Image.network("${listItem.eyecathing.toString()}?w=64&h=64&fit=crop"), //microCMSの画像変更機能を利用
              ),
              title: Text(listItem.title),
              // title: const Text("タイトル"),
              subtitle: Text(listItem.publishedAt.toIso8601String()),

              // ここのコメントアウトを外すとエラー発生→138行目のコード変更で解消？

              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return MyAppDetail(id: listItem.id);
                    },
                  ),
                );
              },
            ),
          )
        ).toList(),
      ),
    );
  }
}

class ListItem {
  final String id;
  final String title;
  final DateTime publishedAt;
  final Uri eyecathing;

  ListItem(this.id, this.title, this.publishedAt, this.eyecathing);

  // ListItem.fromJSON(Map<String, dynamic> json)
  //   : id = json['id'],
  //       title = json['title'],
  //       publishedAt = DateTime.parse(json['publishedAt']),
  //       eyecathing = Uri.parse(json['eyecatching']['url']);

  ListItem.fromJSON(Map<String, dynamic> json)
    : id = json['id'],
        title = json['title'],
        publishedAt = DateTime.parse(json['publishedAt']),
        eyecathing = Uri.parse(json['eyecatching']['url']);

}


//詳細画面
class MyAppDetail extends StatefulWidget {
  final String id;

  // const MyAppDetail({required Key key, required this.id}) : super(key: key);
  // const MyAppDetail({ required Key key, required this.id}) : super(key: key);

  //変更箇所
  const MyAppDetail({Key?key, required this.id}) : super(key: key);

  @override
  _MyAppDetailState createState() => _MyAppDetailState();
}

class _MyAppDetailState extends State<MyAppDetail> {
  // late Map<String, dynamic> item;
  Map<String, dynamic>? item;
  // _item? <ListItem>[];
  // List? item;

  late final WebViewController _controller;
  bool _isLoading = false;

  void _loadDetail(String id) async {
    final result = await http.get(
        Uri.parse('$endpoint$id'),
        headers: { "X-API-KEY": apiKey }
    );
    print('$endpoint$id');
    // print(result.body);
    setState(() {
      // item != null ? 
      item = json.decode(result.body);
      // print(item);

    });
  }

  @override
  void initState() {
    super.initState();
      _loadDetail(widget.id);
      _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) async {
              setState(() {
                _isLoading = false;
              });
            },
          ),
        )
      // ..loadRequest(Uri.parse('https://flutter.dev'));
      ..loadRequest(Uri.parse('$endpoint/$widget.id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('記事詳細'),
      ),
      // ignore: unnecessary_null_comparison
      body: item != null ?
      Column(
        children: [
          Image.network(item!['eyecatching']['url']),
          Container(
            decoration: new BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item!['title'],
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                // WebViewWidget(controller: _controller),
                // SingleChildScrollView(child: item!['body'])
                Text(
                  item!['body'],
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.left,
                ),
                // ここのコメントアウトを外すとエラー発生
                // ConstrainedBox(
                  // constraints: BoxConstraints(maxHeight: 290),
                  // child:
                  //   WebViewWidget(
                  //     controller: WebViewController()
                  //     initialUrl: 'about:blank',
                  //     onWebViewCreated: (webViewController) {
                  //       webViewController.loadUrl(Uri.dataFromString(
                  //           item['body'],
                  //           mimeType: 'text/html',
                  //           encoding: utf8
                  //       ).toString());
                  //     },
                  //   )


                    //  WebView(
                    //   initialUrl: 'about:blank',
                    //   onWebViewCreated: (webViewController) {
                    //     webViewController.loadUrl(Uri.dataFromString(
                    //         item['body'],
                    //         mimeType: 'text/html',
                    //         encoding: utf8
                    //     ).toString());
                    //   },
                    // )
                // ),
              ],
            ),
          )
        ],
      ) :
      const Center(child: Text('読み込み中')) ,
    );
  }
}















// class Article{
//   final String id;
//   final String title;
//   final DateTime publishedAt;
//   final Uri eyecathing;

//   Article(this.id, this.title, this.publishedAt, this.eyecathing);

//   Article.fromJson(Map<String, dynamic> json)
//     : id = json['id'],
//         title = json['title'],
//         publishedAt = DateTime.parse(json['publishedAt']),
//         eyecathing = Uri.parse(json['eyecatching']['url']);
// }