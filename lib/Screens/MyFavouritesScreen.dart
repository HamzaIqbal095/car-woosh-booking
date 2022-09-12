import 'package:flutter/material.dart';
import 'package:woooosh/Firebase/FirebaseDataBaseService.dart';
import 'package:woooosh/Objects/CompanyObject.dart';
import 'package:woooosh/Utils/Colors.dart';
import 'package:woooosh/Utils/Global.dart';
import 'package:woooosh/Utils/UtilWidgets.dart';

class MyFavouritesScreen extends StatefulWidget {
  @override
  _MyFavouritesScreenState createState() => _MyFavouritesScreenState();
}

class _MyFavouritesScreenState extends State<MyFavouritesScreen> {
  List<CompanyObject> _companies = [];
  bool buttonLoading = false;

  Future<void> getCompanies() async {
    List<CompanyObject> companiesData =
        await FirebaseDataBaseService().getCompaniesList();

    if (companiesData != null) {
      setState(() {
        print(
            '${companiesData.length} length is & ${companiesData[0].imageName}');
        _companies = companiesData;
      });
    }
  }

  @override
  initState() {
    super.initState();
    getCompanies();
  }

  CompanyObject getCompanyFavourite({@required String id}) {
    CompanyObject have;
    _companies.forEach((favouriteData) {
      if (id == favouriteData.id) {
        have = favouriteData;
      }
    });
    return have;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _bodyView(),
      ),
    );
  }

  Widget _bodyView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: backgroundColor,
      ),
      child: Column(
        children: [
          // _headingsView(),
          appBarView(
            label: 'My Favourites',
            function: () => Navigator.pop(context),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: _detailsView(),
          ),
        ],
      ),
    );
  }

  Widget _detailsView() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          itemCount: favouriteCompanies.length,
          itemBuilder: (context, index) {
            return DialogUtilsView(
              company: getCompanyFavourite(
                id: favouriteCompanies[index],
              ),
              service: null,
            );
          }),
    );
  }
}
