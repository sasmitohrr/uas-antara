import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nsc_hris/login_page.dart';
import 'package:http/http.dart' as http;
import 'clocking.dart';
import 'navigation.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String photo = "";
  String username = "";
  String firstName = "";
  String lastName = "";
  List precenseUser = [];
  Timer? _timer;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const PageLogin(),
        ),
        (route) => false,
      );
    }
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove("username");
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const PageLogin(),
      ),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
        "Berhasil logout",
        style: TextStyle(fontSize: 16),
      )),
    );
  }

  @override
  void initState() {
    super.initState();
    getPref();
    _getData();
    _getPrecence();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    //EasyLoading.showSuccess('Use in initState');
  }

  @override
  dispose() {
    super.dispose();
  }

  

  Future _getData() async {
    print(username);
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          //get detail data with id

          "http://nscis.nsctechnology.com/index.php?r=user/view-api&id='${username}'"));

      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          photo = data["photo"];
          firstName = data["first_name"];
          lastName = data["last_name"];
          //print(userId);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future _getPrecence() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      final response = await http.get(Uri.parse(
          //you have to take the ip address of your computer.
          //because using localhost will cause an error
          // "http://nscis.nsctechnology.com/index.php?r=precense/list"
          "http://nscis.nsctechnology.com/index.php?r=precense/user-api&id='${username}'"));

      // if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // entry data to variabel list _get
        setState(() {
          precenseUser = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  showImage(String image) {
    
          if (image.length % 4 > 0) { 
            image += '=' * (4 - image .length % 4); // as suggested by Albert221
        }

        

    
      
    return Image.memory(
      base64Decode(image),
    );
  }

  final List<String> _listItem = [
    'assets/images/two.jpg',
    'assets/images/three.jpg',
    'assets/images/four.jpg',
    'assets/images/five.jpg',
    'assets/images/one.jpg',
    'assets/images/two.jpg',
    'assets/images/three.jpg',
    'assets/images/four.jpg',
    'assets/images/five.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Icon(Icons.menu),
        title: Text("N-HR"),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image:
                        NetworkImage("http://nscis.nsctechnology.com/" + photo),
                    fit: BoxFit.fill),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      body:  SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                        image: AssetImage('assets/images/background1.jpg'),
                        fit: BoxFit.cover)),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient:
                          LinearGradient(begin: Alignment.bottomRight, colors: [
                        Colors.black.withOpacity(.4),
                        Colors.black.withOpacity(.2),
                      ])),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Hi, ${firstName} ${lastName}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Welcome to N-HR Mobile",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 40),
                        // decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(10),
                        //     color: Colors.white),
                        child: Center(
                          child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.amber,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: const BorderSide(color: Colors.white),
                                  ),
                                  elevation: 10,
                                  minimumSize: const Size(200, 58)),
                                  
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => Clocking()));
                                setState(() {});
                              },
                              icon: const Icon(Icons.arrow_right_alt),
                              label: const Text(
                                "Clocking",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )),
                          
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
               SizedBox(
                height: 30,
                child: Container(
                  child: Column(
                    children: [
                      Text("MENU", textAlign: TextAlign.right,style: TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
                    ],
                      // child: Text("Menu", style: TextStyle(
                  //                     fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
               ),
              Expanded(
                
                child: Container(
                  // decoration:
                  // BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
              
                  child: GridView(
                    shrinkWrap: true,
                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10, 
                      mainAxisSpacing: 10),
                      children: [
                        Container(
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                            ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            
                            children: [
                              Icon(Icons.checklist_outlined, size: 50, color: Colors.amber,),
                              SizedBox(
                                height: 3,
                              ),
                              Text("Action Required", style: TextStyle(
                                    fontSize: 12),),
                            ],
                          ),
                          ),
                          Container(
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                            ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.announcement, size: 50, color: Colors.amber,),
                              SizedBox(
                                height: 3,
                              ),
                              Text("Annouuncement", style: TextStyle(
                                    fontSize: 12),),
                            ],
                          ),
                          ),
                          Container(
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                            ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_today, size: 50, color: Colors.amber,),
                              SizedBox(
                                height: 3,
                              ),
                              Text("Calendar", style: TextStyle(
                                    fontSize: 12),),
                            ],
                          ),
                          ),
                          Container(
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                            ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.file_open_outlined, size: 50, color: Colors.amber,),
                              SizedBox(
                                height: 3,
                              ),
                              Text("Files", style: TextStyle(
                                    fontSize: 12),),
                            ],
                          ),
                          ),
                          Container(
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                            ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.manage_history, size: 50, color: Colors.amber,),
                              SizedBox(
                                height: 3,
                              ),
                              Text("Attendance", style: TextStyle(
                                    fontSize: 12),),
                            ],
                          ),
                          ),
                          Container(
                          decoration:BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                            ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time_rounded, size: 50, color: Colors.amber,),
                              SizedBox(
                                height: 3,
                              ),
                              Text("Leave", style: TextStyle(
                                    fontSize: 12),),
                            ],
                          ),
                          ),
                        
                      ],
                  ),
                ),
              )
              // Container(
              //   child: precenseUser.isEmpty ? Center(child: Text('')) : Expanded(
              //       child:ListView.builder(
              //           itemCount: precenseUser.length,
              //           shrinkWrap: true,
              //           itemBuilder: (context, index) {
              //             return Container(
              //               width: MediaQuery.of(context).size.width,
              //               padding: EdgeInsets.symmetric(
              //                   horizontal: 5.0, vertical: 5.0),
              //               child: Card(
              //                 margin: EdgeInsets.symmetric(
              //                     vertical: 2, horizontal: 2),
              //                 elevation: 5.0,
              //                 child: ListTile(
              //                   leading: showImage(precenseUser[index]['photo']),
              //                   title: Text(precenseUser[index]['date'] +' '+ precenseUser[index]['time'],
              //                       style: TextStyle(
              //                           color: Colors.black,
              //                           fontSize: 18.0,
              //                           fontWeight: FontWeight.bold)),
              //                   subtitle: Text('Location: ' + precenseUser[index]['location']),
              //                 ),
              //               ),
              //             );
              //           })),
              // ),
              // Expanded(
              //     child: GridView.count(
              //   crossAxisCount: 2,
              //   children: [
              //     CustomCard(
              //         title: "Report", image: "assets/images/report.jpg"),
              //     CustomCard(title: "Leave", image: "assets/images/leave3.jpg"),
              //     CustomCard(
              //         title: "Calender", image: "assets/images/calender.jpg"),
              //     CustomCard(
              //         title: "Announcement",
              //         image: "assets/images/announce.jpg"),
              //   ],
              // ))
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  //ini adalah konstruktor, saat class dipanggil parameter konstruktor wajib diisi
  //parameter ini akan mengisi title dan gambar pada setiap card
  CustomCard({required this.title, required this.image});

  String title;
  String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Card(
        //menambahkan bayangan
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(
                        image,
                      ),
                      fit: BoxFit.fill)),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Center(
                  child: Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, height: 2, fontSize: 14),
              )),
            )
          ],
        ),
      ),
    );
  }
}
