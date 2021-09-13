import 'dart:convert';
import 'package:ecommerece_velocity_app/models/address.dart';
import 'package:ecommerece_velocity_app/screens/adresss/create_address/add_adress.dart';
import 'package:ecommerece_velocity_app/screens/adresss/update_address/update_address.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants.dart';
import '../../../size_config.dart';
import '../../sign_in/sign_in_screen.dart';
import 'package:http/http.dart' as http;


class AddressBody extends StatefulWidget {
  const AddressBody({Key? key}) : super(key: key);

  @override
  _ProfileBody createState() => _ProfileBody();
}
class _ProfileBody extends State<AddressBody> {
  late SharedPreferences sharedPreferences;
  late List<Address> allAddressList;
  @override
  void initState() {
    addressList();
    super.initState();
    loginStatus();
  }

  loginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SignInPage()), (Route<dynamic> route) => false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: addressList(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.data == null){
            return Center(
                //child:
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    value: snapshot.data,
                    semanticsLabel: 'Progress indicator',
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  const Text(
                    'Please wait while it is loading.. ',
                  ),
                ],
              ),

            );
          } else {
            return ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    color: const Color(0xFFF5F6F9),
                    //primary: kPrimaryColor,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0.0,
                    //backgroundColor: const Color(0xFFF5F6F9),
                    child: ListTile(
                      title: Text(snapshot.data[index].address1[0]),
                      subtitle: Text(snapshot.data[index].city),
                      onTap: (){
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => UpdateAddressScreen(AddressID: snapshot.data[index],)), (Route<dynamic> route) => true);
                      },
                      trailing: const Icon(Icons.arrow_forward_ios),
                    )
                );
              },
            );
          }
        },
      ),
    );
  }
  Future<List<Address>> addressList() async {
    List<Address> allAddressList;
    String url = serverUrl + "addresses";
    sharedPreferences = await SharedPreferences.getInstance();
    final name = sharedPreferences.getString('cookies') ?? '';
    var response = await http.get(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Cookie':name,
          'Connection': 'keep-alive',
        }
    );
    if(response.statusCode == 200) {
      var jsonResponse = await json.decode(response.body);

      if(jsonResponse != null) {
        allAddressList = addressListFromJson(response.body).data;
        return allAddressList;
      }
    }
    else {
    }
    throw ("Not found");
  }
}
