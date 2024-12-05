import 'dart:io';

import 'package:chat_app/widget/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  final _form = GlobalKey<FormState>();
  File? _selectImage;
  var _isAuthenfication = false;
  var _username = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectImage == null) {
      return;
    }

    _form.currentState!.save();

    try {
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user?.uid}.jpg');

        await storageRef.putFile(_selectImage!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredentials.user?.uid)
            .set({
          'username': _username,
          'email': _enteredEmail,
          'password': _enteredPassword,
          'image_url': imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentification error')),
      );
    }
    if (mounted) {
      setState(() {
        _isAuthenfication = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                      top: 30, bottom: 20, left: 20, right: 20),
                  width: 200,
                  child: Image.asset('assets/img/chat.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              UserImagePicker(
                                onPickedImage: (pickedImage) {
                                  _selectImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Addres',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return "Please enter a valid email address";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 4) {
                                    return "Password enter at least 4 characters ";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _username = value!;
                                },
                              ),
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.trim().length < 8) {
                                  return "Password must be at least 8 characters long";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredPassword = value!;
                              },
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            if (_isAuthenfication)
                              const CircularProgressIndicator(),
                            if (!_isAuthenfication)
                              ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                ),
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            if (!_isAuthenfication)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(_isLogin
                                    ? 'Create an account'
                                    : 'I have an account. Login.'),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
