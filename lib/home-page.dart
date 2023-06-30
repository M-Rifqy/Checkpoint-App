import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/models/home-response.dart';
import 'package:presensi/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future getData() async {
    final Map<String, String> headres = {
      'Authorization': 'Bearer ' + await _token
    };
    var response = await myHttp.get(
        Uri.parse('http://10.0.2.2:8000/api/get-presensi'),
        headers: headres);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if (element.isHariIni) {
        hariIni = element;
      } else {
        riwayat.add(element);
      }
    });
  }

  Future<void> _logout() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.clear(); // Clear all stored preferences
    // Navigate to the login screen or any other screen you want
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5F2CED),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image(
            image: AssetImage('assets/checkpoint.png'),
          ),
        ),
        title: Text(
          'Checkpoint',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              return SafeArea(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder(
                        future: _name,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else {
                            if (snapshot.hasData) {
                              print(snapshot.data);
                              return Text(snapshot.data!,
                                  style: TextStyle(fontSize: 18));
                            } else {
                              return Text("-", style: TextStyle(fontSize: 18));
                            }
                          }
                        }),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 400,
                      decoration: BoxDecoration(
                        color: Color(0xFF5F2CED),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          Text(hariIni?.tanggal ?? '-',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(hariIni?.masuk ?? '-',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24)),
                                  Text("Masuk",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16))
                                ],
                              ),
                              Column(
                                children: [
                                  Text(hariIni?.pulang ?? '-',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24)),
                                  Text("Pulang",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16))
                                ],
                              )
                            ],
                          )
                        ]),
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 16.0),
                      child: Text("Riwayat Absensi"),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: riwayat.length,
                        itemBuilder: (context, index) => Card(
                          child: ListTile(
                            leading: Text(riwayat[index].tanggal),
                            title: Row(children: [
                              Column(
                                children: [
                                  Text(riwayat[index].masuk,
                                      style: TextStyle(fontSize: 18)),
                                  Text("Masuk", style: TextStyle(fontSize: 14))
                                ],
                              ),
                              SizedBox(width: 20),
                              Column(
                                children: [
                                  Text(riwayat[index].pulang,
                                      style: TextStyle(fontSize: 18)),
                                  Text("Pulang", style: TextStyle(fontSize: 14))
                                ],
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => SimpanPage()))
              .then((value) {
            setState(() {});
          });
        },
        backgroundColor: Color(0xFF5F2CED),
        child: Icon(Icons.add),
      ),
    );
  }
}
