import 'package:click_charger/game/game_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../game/game_state.dart';

class FirestoreModel {
  static const String usersCollectionId = 'users';

  static CollectionReference _userCollection;

  static CollectionReference get usersCollection {
    if (_userCollection == null) {
      _userCollection =
          FirebaseFirestore.instance.collection(usersCollectionId);
    }

    return _userCollection;
  }

  static Future<void> createGameState(String uid, GameData gameData) async {
    GameState gameState = GameState(gameData: gameData);
    await usersCollection
        .doc(uid)
        .set(gameState.toFirestoreJson())
        .catchError((error) {
      print('Failed to add document for $uid: $error');
    });
  }

  static Future<GameState> getOrCreateGameState(String uid) async {
    DocumentSnapshot snapshot = await usersCollection.doc(uid).get().catchError(
      (error) {
        print('Failed to get document for $uid: $error');
      },
    );

    if (snapshot != null && snapshot.exists) {
      return GameState.fromFirestoreJson(snapshot.data());
    }

    return null;
  }

  static Future<void> updateGameState(String uid, GameState gameState) async {
    var data = gameState.toFirestoreJson();
    data.remove('boostCount');
    data.remove('boostEndTime');
    data.remove('isRemoveAd');
    data.remove('nextRewardedAdTime');

    await usersCollection.doc(uid).update(data).catchError((error) {
      print('Failed to update document for $uid: $error');
    });
  }
}
