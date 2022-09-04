/*
 * Copyright (c) 2021 Akshay Jadhav <jadhavakshay0701@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:food_delivery_app/models/Users.dart';

class AuthMethods {

  // Firebase auth, will use to get user info and registration and signing 
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase Database, will use to get reference.
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  static final DatabaseReference _userReference = _database.reference().child("Users");

  // current user getter
  Future<User> getCurrentUser() async {
    User? fUser;
    fUser = await _auth.currentUser;
    return fUser!;
  }

  // gets auth state of user through out the life cycle of the app
  Stream<User?> get onAuthStateChanged {
    return _auth.authStateChanges();
  }

  //sign in current user with email and password
  Future<User> handleSignInEmail(String email, String password) async {

    UserCredential result =
    await _auth.signInWithEmailAndPassword(email: email, password: password);

    final User user = result.user!;

    assert(user != null);
    assert(await user.getIdToken() != null);
    final User? fUser = await _auth.currentUser;
    assert(user.uid == fUser?.uid);

    print('signInEmail succeeded: $user');

    return user;
  }

  // register new user with phone email password details
  Future<User> handleSignUp(phone, email, password) async {

    UserCredential result =
    await _auth.createUserWithEmailAndPassword(email: email, password: password);

    final User user = result.user!;

    assert (user != null);
    assert (await user.getIdToken() != null);
    await addDataToDb(user, email, phone, password);
    return user;
  }

  // after sign up, add user data to firebase realtime database
  Future<void> addDataToDb(User currentUser, String username,
      String phone, String password) async {
    
    Users user = Users(
        uid: currentUser.uid,
        email: currentUser.email,
        phone: phone,
        password: password
    );

    _userReference
        .child(currentUser.uid)
        .set(user.toMap(user));
  }

  // Logs out current user from the application
  Future<void> logout() async {
    await _auth.signOut();
  }
}