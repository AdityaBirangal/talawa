//flutter packages are imported here
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//PAges are imported here
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:talawa/controllers/auth_controller.dart';
import 'package:talawa/controllers/org_controller.dart';
import 'package:talawa/services/Queries.dart';
import 'package:talawa/services/preferences.dart';
import 'package:talawa/utils/GQLClient.dart';
import 'package:talawa/utils/globals.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:talawa/views/pages/home_page.dart';
import 'package:talawa/views/pages/organization/profile_page.dart';

import 'create_organization.dart';

class JoinOrganization extends StatefulWidget {
  JoinOrganization({Key key, this.msg});

  final String msg;
  @override
  _JoinOrganizationState createState() => _JoinOrganizationState();
}

class _JoinOrganizationState extends State<JoinOrganization> {
  Queries _query = Queries();
  Preferences _pref = Preferences();
  String token;
  static String itemIndex;
  GraphQLConfiguration graphQLConfiguration = GraphQLConfiguration();
  FToast fToast;
  List organizationInfo = List();
  List filteredOrgInfo = List();
  List joinedOrg = [];
  AuthController _authController = AuthController();
  String isPublic;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    //creating the initial state for all the variables
    super.initState();
    fToast = FToast();
    fToast.init(context);
    fetchOrg();
  }

  void searchOrgName(String orgName) {
    //it is the search bar to search the organization
    filteredOrgInfo.clear();
    if (orgName.isNotEmpty) {
      for (int i = 0; i < organizationInfo.length; i++) {
        String name = organizationInfo[i]['name'];
        if (name.toLowerCase().contains(orgName.toLowerCase())) {
          setState(() {
            filteredOrgInfo.add(organizationInfo[i]);
          });
        }
      }
    } else {
      setState(() {
        filteredOrgInfo.add(organizationInfo);
      });
    }
  }

  Future fetchOrg() async {
    //function to fetch the org from the server
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client
        .query(QueryOptions(documentNode: gql(_query.fetchOrganizations)));
    if (result.hasException) {
      print(result.exception);
      showError(result.exception.toString());
    } else if (!result.hasException) {
      setState(() {
        organizationInfo = result.data['organizations'];
      });
    }
  }

  Future joinPrivateOrg() async {
    //function called if the person wants to enter a private organization
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client.mutate(MutationOptions(
        documentNode: gql(_query.sendMembershipRequest(itemIndex))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      return joinPrivateOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.loading) {
      print(result.data);
      _successToast("Request Sent to Organization Admin");

      pushNewScreen(
        context,
        screen: ModalRoute.of(context).settings.name == '/profile_page'
            ? ProfilePage()
            : HomePage(),
      );
    }
  }

  Future joinPublicOrg() async {
    //function which will be called if the person wants to join the organization which is not private
    GraphQLClient _client = graphQLConfiguration.authClient();

    QueryResult result = await _client
        .mutate(MutationOptions(documentNode: gql(_query.getOrgId(itemIndex))));

    if (result.hasException &&
        result.exception.toString().substring(16) == accessTokenException) {
      _authController.getNewToken();
      return joinPublicOrg();
    } else if (result.hasException &&
        result.exception.toString().substring(16) != accessTokenException) {
      _exceptionToast(result.exception.toString().substring(16));
    } else if (!result.hasException && !result.loading) {
      setState(() {
        joinedOrg =
            result.data['joinPublicOrganization']['joinedOrganizations'];
      });

      //set the default organization to the first one in the list
      if (joinedOrg.length == 1) {
        final String currentOrgId = result.data['joinPublicOrganization']
            ['joinedOrganizations'][0]['_id'];
        await _pref.saveCurrentOrgId(currentOrgId);
        final String currentOrgImgSrc = result.data['joinPublicOrganization']
            ['joinedOrganizations'][0]['image'];
        await _pref.saveCurrentOrgImgSrc(currentOrgImgSrc);
        final String currentOrgName = result.data['joinPublicOrganization']
            ['joinedOrganizations'][0]['name'];
        await _pref.saveCurrentOrgName(currentOrgName);
      }
      _successToast("Sucess!");

      //Navigate user to newsfeed
      pushNewScreen(
        context,
        screen: ModalRoute.of(context).settings.name == '/profile_page'
            ? ProfilePage()
            : HomePage(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Organization',
            style: const TextStyle(color: Colors.white)),
      ),
      body: organizationInfo.isEmpty
          ? const Center(child: const CircularProgressIndicator())
          : Container(
              color: const Color(0xffF3F6FF),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
              child: Column(
                children: <Widget>[
                  const Text(
                    "Welcome, \nJoin or Create your organization to get started",
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontStyle: FontStyle.normal),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    onChanged: (value) {
                      searchOrgName(value);
                    },
                    controller: searchController,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(5),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 0.0),
                        ),
                        prefixIcon: const Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: const Icon(Icons.search, color: Colors.black),
                        ),
                        hintText: "Search Organization Name"),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                      child: Container(
                          color: const Color(0xffF3F6FF),
                          child: searchController.text.isNotEmpty
                              ? ListView.builder(
                                  itemCount: filteredOrgInfo.length,
                                  itemBuilder: (context, index) {
                                    final organization = filteredOrgInfo[index];
                                    return Card(
                                      child: ListTile(
                                        leading: organization['image'] != null
                                            ? CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                    Provider.of<GraphQLConfiguration>(
                                                                context)
                                                            .displayImgRoute +
                                                        organization['image']))
                                            : const CircleAvatar(
                                                radius: 30,
                                                backgroundImage: const AssetImage(
                                                    "assets/images/team.png")),
                                        title: organization['isPublic']
                                                    .toString() !=
                                                'false'
                                            ? Row(
                                                children: [
                                                  Text(organization['name']
                                                      .toString()),
                                                  const Icon(
                                                    Icons.lock_open,
                                                    color: Colors.green,
                                                    size: 16,
                                                  )
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Text(organization['name']
                                                      .toString()),
                                                  const Icon(
                                                    Icons.lock,
                                                    color: Colors.red,
                                                    size: 16,
                                                  )
                                                ],
                                              ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                organization['description']
                                                    .toString(),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            Text(
                                                'Created by: ' +
                                                    organization['creator']
                                                            ['firstName']
                                                        .toString() +
                                                    ' ' +
                                                    organization['creator']
                                                            ['lastName']
                                                        .toString(),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ],
                                        ),
                                        trailing: new RaisedButton(
                                            onPressed: () {
                                              itemIndex = organization['_id']
                                                  .toString();
                                              if (organization['isPublic']
                                                      .toString() ==
                                                  'false') {
                                                setState(() {
                                                  isPublic = 'false';
                                                });
                                              } else {
                                                setState(() {
                                                  isPublic = 'true';
                                                });
                                              }
                                              confirmOrgDialog();
                                            },
                                            color: UIData.primaryColor,
                                            child: const Text("JOIN"),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                            )),
                                        isThreeLine: true,
                                      ),
                                    );
                                  })
                              : ListView.builder(
                                  itemCount: organizationInfo.length,
                                  itemBuilder: (context, index) {
                                    final organization =
                                        organizationInfo[index];
                                    return Card(
                                      child: ListTile(
                                        leading: organization['image'] != null
                                            ? CircleAvatar(
                                                radius: 30,
                                                backgroundImage: NetworkImage(
                                                    Provider.of<GraphQLConfiguration>(
                                                                context)
                                                            .displayImgRoute +
                                                        organization['image']))
                                            : const CircleAvatar(
                                                radius: 30,
                                                backgroundImage: const AssetImage(
                                                    "assets/images/team.png")),
                                        title: organization['isPublic']
                                                    .toString() !=
                                                'false'
                                            ? Row(
                                                children: [
                                                  Text(organization['name']
                                                      .toString()),
                                                  const Icon(
                                                    Icons.lock_open,
                                                    color: Colors.green,
                                                    size: 16,
                                                  )
                                                ],
                                              )
                                            : Row(
                                                children: [
                                                  Text(organization['name']
                                                      .toString()),
                                                  const Icon(
                                                    Icons.lock,
                                                    color: Colors.red,
                                                    size: 16,
                                                  )
                                                ],
                                              ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                organization['description']
                                                    .toString(),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            Text(
                                                'Created by: ' +
                                                    organization['creator']
                                                            ['firstName']
                                                        .toString() +
                                                    ' ' +
                                                    organization['creator']
                                                            ['lastName']
                                                        .toString(),
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ],
                                        ),
                                        trailing: new RaisedButton(
                                            onPressed: () {
                                              itemIndex = organization['_id']
                                                  .toString();
                                              if (organization['isPublic']
                                                      .toString() ==
                                                  'false') {
                                                setState(() {
                                                  isPublic = 'false';
                                                });
                                              } else {
                                                setState(() {
                                                  isPublic = 'true';
                                                });
                                              }
                                              confirmOrgDialog();
                                            },
                                            color: UIData.primaryColor,
                                            child: const Text("JOIN"),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      12.0),
                                            )),
                                        isThreeLine: true,
                                      ),
                                    );
                                  })))
                ],
              )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: UIData.secondaryColor,
        foregroundColor: Colors.white,
        elevation: 5.0,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => new CreateOrganization()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void confirmOrgDialog() {
    //this is the pop up shown when the confirmation is required
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirmation"),
            content:
                const Text("Are you sure you want to join this organization?"),
            actions: [
              FlatButton(
                child: const Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: const Text("Yes"),
                onPressed: () async {
                  if (isPublic == 'true') {
                    joinPublicOrg();
                    Navigator.of(context).pop();
                  } else if (isPublic == 'false') {
                    joinPrivateOrg();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

  Widget showError(String msg) {
    return Center(
      child: Text(
        msg,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  _successToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.green,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }

  _exceptionToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.red,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 3),
    );
  }
}
