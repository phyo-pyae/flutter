import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phyopyaewa_logistics/app/home/models/avatar_reference.dart';
import 'package:phyopyaewa_logistics/app/home/models/image.dart';
import 'package:phyopyaewa_logistics/app/home/models/job.dart';
import 'package:phyopyaewa_logistics/common_widgets/avatar.dart';
import 'package:phyopyaewa_logistics/services/database.dart';
import 'package:phyopyaewa_logistics/services/firebase_storage_service.dart';
import 'package:phyopyaewa_logistics/services/firestore_service.dart';
import 'package:phyopyaewa_logistics/services/image_picker_service.dart';
import 'package:provider/provider.dart';
import 'package:phyopyaewa_logistics/common_widgets/show_alert_dialog.dart';
import 'package:phyopyaewa_logistics/services/auth.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:async/async.dart';

class ReportPage extends StatefulWidget {
  final BuildContext context;

  const ReportPage({Key key, this.context}) : super(key: key);

  static Future<void> show(BuildContext context, Job job) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: false,
        builder: (context) => ReportPage(
          context: context,
        ),
      ),
    );
  }

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedFiles = [];
  List<String> _arrayImageUrls = [];
  int uploadItem = 0;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _issueController.dispose();
    super.dispose();
  }

  static Future<void> show(BuildContext context) async {
    await Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: false,
        builder: (context) => ReportPage(
          context: context,
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage
  Future<void> _chooseAvatar(String inputSource, BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final database = Provider.of<Database>(context, listen: false);
    final picker = ImagePicker();
    XFile pickedImage;
    try {
      pickedImage = await picker.pickImage(
          source: inputSource == 'camera'
              ? ImageSource.camera
              : ImageSource.gallery,
          maxWidth: 1920);

      final String fileName = path.basename(pickedImage.path);
      final String currentUser = auth.currentUser.uid;
      final String name =
          fileName.replaceAll(fileName, 'users/${currentUser}/profile.jpg');
      print(name);
      File imageFile = File(pickedImage.path);

      try {
        // Uploading the selected image with some custom meta data
        TaskSnapshot snapshot = await storage.ref(name).putFile(
            imageFile,
            SettableMetadata(customMetadata: {
              'user': 'A bad guy',
              'description': 'Some description...'
            }));

        // if (snapshot == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        ImageModel image = ImageModel(url: '$downloadUrl');
        print(downloadUrl);
        String documentIdFromCurrentDate() => DateTime.now().toIso8601String();
        // ${documentIdFromCurrentDate()}
        final path = "/images/${currentUser.toString()}";
        final reference = FirebaseFirestore.instance.doc(path);

        print('$path');
        await reference.set({"url": downloadUrl, "name": name});
//          await database.addImage(image);

        // await FirebaseFirestore.instance
        //     .collection("")
        //     .add({"url": downloadUrl, "name": name});

        // }

        // Refresh the UI
        setState(() {});
      } on FirebaseException catch (error) {
        if (kDebugMode) {
          print('error');
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print('error');
      }
    }
  }

// Retriew the uploaded images
  // This function is called when the app launches for the first time or when an image is uploaded or deleted
  Future<List<Map<String, dynamic>>> _loadImages(BuildContext context) async {
    List<Map<String, dynamic>> files = [];
    final auth = Provider.of<AuthBase>(context, listen: false);
    final String currentUser = auth.currentUser.uid;

    final ListResult result = await storage.ref('users/$currentUser').list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath,
        "user": fileMeta.customMetadata['user'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata['description'] ?? 'No description'
      });
    });

    return files;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  Widget showLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Uploading: ' +
              uploadItem.toString() +
              "/" +
              _selectedFiles.length.toString()),
          SizedBox(
            height: 30,
          ),
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  void uploadFunction(List<XFile> _images, BuildContext cont) {
    setState(() {
      _isLoading = true;
    });
    for (int i = 0; i < _images.length; i++) {
      var imageUrl = uploadFile(_images[i], context);
      _arrayImageUrls.add(imageUrl.toString());
    }
  }

  Future<String> uploadFile(XFile _image, BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    final String currentUser = auth.currentUser.uid;
    final String currentUserEmail = auth.currentUser.email;
    final String _timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    Reference reference =
        storage.ref().child("users/$currentUser").child(_image.name);

    UploadTask uploadTask = reference.putFile(
        File(_image.path),
        SettableMetadata(customMetadata: {
          'user': currentUserEmail,
          'description': _issueController.text.toString(),
        }));

    // TaskSnapshot snapshot = await storage.ref(name).putFile(
    // final String downloadUrl = await uploadTask.getDownloadURL();
    // ImageModel image = ImageModel(url: '$downloadUrl');
    // print(downloadUrl);
    // String documentIdFromCurrentDate() => DateTime.now().toIso8601String();
    // // ${documentIdFromCurrentDate()}
    // final path = "/images/${currentUser.toString()}";
    // final reference = FirebaseFirestore.instance.doc(path);
    //
    // print('$path');
    // await reference.set({"url": downloadUrl, "name": name});
    uploadTask.whenComplete(() {
      setState(() {
        uploadItem++;
        if (uploadItem == _selectedFiles.length) {
          _isLoading = false;
          uploadItem = 0;
        }
      });
    });
    return await reference.getDownloadURL();
  }

  Future<void> selectImages() async {
    if (_selectedFiles != null) {
      _selectedFiles.clear();
    }
    try {
      final List<XFile> imgs = await _picker.pickMultiImage(imageQuality: 88);
      if (imgs.isNotEmpty) {
        print(imgs.length);
        _selectedFiles.addAll(imgs);
      }
      print("List Of Selected Images:" + imgs.length.toString());
    } catch (e) {
      print('Something Wrong' + e.toString());
    }
    setState(() {});
  }

  Future<void> clearImages() async {
    if (_selectedFiles != null) {
      _selectedFiles.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
        actions: <Widget>[
          TextButton(
            onPressed: () => _confirmSignOut(context),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: _buildUserInfo(auth.currentUser, context),
        ),
      ),
      body: _isLoading
          ? showLoading()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        selectImages();
                      },
                      child: Text('Select Files'),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        clearImages();
                        _issueController.clear();
                      },
                      child: Text('Clear Files'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_selectedFiles.isNotEmpty &&
                            _formKey.currentState.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                          uploadFunction(_selectedFiles, context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Files: " +
                                  _selectedFiles.length.toString())));
                          print(_issueController.text);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Please Select Image")));
                        }
                      },
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Upload'),
                    ),

                    // Visibility(
                    //   visible: true,
                    //   child: ElevatedButton.icon(
                    //       onPressed: () => _chooseAvatar('camera', context),
                    //       icon: const Icon(Icons.camera),
                    //       label: const Text('camera')),
                    // ),
                    // Visibility(
                    //   visible: true,
                    //   child: ElevatedButton.icon(
                    //       onPressed: () => _chooseAvatar('gallery', context),
                    //       icon: const Icon(Icons.library_add),
                    //       label: const Text('Gallery')),
                    // ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: TextFormField(
                        maxLength: 50,
                        controller: _issueController,
                        decoration: InputDecoration(
                          labelText: 'Issue',
                          hintText: 'e.g. Truck Tire Issue',
                        ),
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Issue';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                _selectedFiles.length == 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 1,
                          vertical: 1,
                        ),
                        //no image selected image widget,
                        child: Text(''),
                      )
                    : Expanded(
                        child: GridView.builder(
                          itemCount: _selectedFiles.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Image.file(
                                File(_selectedFiles[index].path),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      ),
                Expanded(
                  child: FutureBuilder(
                    future: _loadImages(context),
                    builder: (context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return ListView.builder(
                          itemCount: snapshot.data?.length ?? 0,
                          itemBuilder: (context, index) {
                            final Map<String, dynamic> image =
                                snapshot.data[index];
                            // Image.file(
                            //   File(_selectedFiles[index].path),
                            //   fit: BoxFit.cover,
                            // ),

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                dense: false,
                                leading: Image.network(
                                  image['url'],
                                ),
                                title: Text(image['description']),
                                subtitle: Text(image['user']),
                                trailing: IconButton(
                                  onPressed: () => _delete(image['path']),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserInfo(User user, BuildContext context) {
    return Column(
      children: <Widget>[
        // Avatar(
        //   onPressed: () => _chooseAvatar('gallery', context),
        //   photoUrl: user.photoURL,
        //   radius: 50,
        // ),
        SizedBox(height: 8),

        if (user.email != null)
          Text(
            user.email,
            style: TextStyle(color: Colors.white),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
