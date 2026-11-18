import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AppStore extends ChangeNotifier {
  final SharedPreferences preferences;
  final bool cloudEnabled;
  AppStore(this.preferences, {this.cloudEnabled = false});
  bool demo = false;
  bool signedIn = false;
  String name = '', email = '', phone = '';
  String? selectedPetId;
  List<Pet> pets = [];
  List<Appointment> appointments = [];
  List<Session> sessions = [];
  Set<String> favorites = {};
  bool _writing = false;
  bool get writing => _writing;
  Pet? get selectedPet {
    for (final pet in pets) {
      if (pet.id == selectedPetId) return pet;
    }
    return pets.isEmpty ? null : pets.first;
  }

  String petName(String id) =>
      pets.where((p) => p.id == id).firstOrNull?.name ?? 'Pet removido';
  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<void> enterDemo({String? tutor, String? contact}) async {
    _clear();
    demo = true;
    final saved = preferences.getString('fisiopet-demo-v1');
    if (saved != null) {
      _load(jsonDecode(saved) as Map<String, dynamic>);
    } else {
      name = 'Tutor';
    }
    if (tutor != null) name = tutor;
    if (contact != null) email = contact;
    signedIn = true;
    notifyListeners();
  }

  Future<void> login(String address, String password) async {
    if (!cloudEnabled) {
      throw StateError(
        'Configure o Firebase para entrar com uma conta ou use Explorar demonstração.',
      );
    }
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: address,
      password: password,
    );
    try {
      await _loadCloud();
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      rethrow;
    }
  }

  Future<void> register(String tutor, String address, String password) async {
    if (!cloudEnabled) {
      await enterDemo(tutor: tutor, contact: address);
      await _persist();
      return;
    }
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: address,
      password: password,
    );
    _clear();
    name = tutor;
    email = address;
    try {
      await _persist();
      signedIn = true;
      notifyListeners();
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      rethrow;
    }
  }

  Future<void> _loadCloud() async {
    _clear();
    final user = FirebaseAuth.instance.currentUser!;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (snapshot.exists) _load(snapshot.data()!);
    email = user.email ?? '';
    if (name.isEmpty) name = 'Tutor';
    signedIn = true;
    notifyListeners();
  }

  Future<void> resetPassword(String address) async {
    if (!cloudEnabled) {
      throw StateError(
        'Recuperação disponível após configurar o Firebase. No modo demonstração, não há senha.',
      );
    }
    await FirebaseAuth.instance.sendPasswordResetEmail(email: address);
  }

  Future<void> logout() async {
    if (cloudEnabled && !demo) await FirebaseAuth.instance.signOut();
    _clear();
    signedIn = false;
    notifyListeners();
  }

  void _clear() {
    demo = false;
    name = '';
    email = '';
    phone = '';
    selectedPetId = null;
    pets = [];
    appointments = [];
    sessions = [];
    favorites = {};
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'selectedPetId': selectedPetId,
    'pets': pets.map((p) => p.toJson()).toList(),
    'appointments': appointments.map((a) => a.toJson()).toList(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
    'favorites': favorites.toList(),
  };
  void _load(Map<String, dynamic> j) {
    name = j['name'] ?? '';
    email = j['email'] ?? '';
    phone = j['phone'] ?? '';
    selectedPetId = j['selectedPetId'];
    pets = (j['pets'] as List? ?? [])
        .map((p) => Pet.fromJson(Map<String, dynamic>.from(p)))
        .toList();
    appointments = (j['appointments'] as List? ?? [])
        .map((a) => Appointment.fromJson(Map<String, dynamic>.from(a)))
        .toList();
    sessions = (j['sessions'] as List? ?? [])
        .map((s) => Session.fromJson(Map<String, dynamic>.from(s)))
        .toList();
    favorites = Set<String>.from(j['favorites'] ?? []);
  }

  Future<void> _persist() async {
    if (demo) {
      final ok = await preferences.setString(
        'fisiopet-demo-v1',
        jsonEncode(toJson()),
      );
      if (!ok) throw StateError('Não foi possível salvar neste dispositivo.');
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw StateError('Entre novamente para salvar.');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(toJson());
    }
  }

  Future<void> _change(VoidCallback action) async {
    if (_writing) throw StateError('Aguarde o salvamento anterior.');
    final previous = toJson();
    _writing = true;
    notifyListeners();
    try {
      action();
      await _persist();
    } catch (_) {
      _load(previous);
      rethrow;
    } finally {
      _writing = false;
      notifyListeners();
    }
  }

  Future<void> savePet(Pet pet) => _change(() {
    pets = [...pets.where((p) => p.id != pet.id), pet];
    selectedPetId = pet.id;
  });
  Future<void> deletePet(String id) => _change(() {
    pets = pets.where((p) => p.id != id).toList();
    appointments = appointments.where((a) => a.petId != id).toList();
    sessions = sessions.where((s) => s.petId != id).toList();
    if (selectedPetId == id) selectedPetId = pets.firstOrNull?.id;
  });
  Future<void> selectPet(String id) => _change(() => selectedPetId = id);
  Future<void> saveProfile(String tutor, String telephone) => _change(() {
    name = tutor;
    phone = telephone;
  });
  Future<void> saveAppointment(Appointment item) => _change(() {
    appointments = [...appointments.where((a) => a.id != item.id), item];
  });
  Future<void> deleteAppointment(String id) => _change(() {
    appointments = appointments.where((a) => a.id != id).toList();
  });
  Future<void> addSession(Session session) =>
      _change(() => sessions = [...sessions, session]);
  Future<void> deleteSession(String id) =>
      _change(() => sessions = sessions.where((s) => s.id != id).toList());
  Future<void> toggleFavorite(String id) => _change(() {
    favorites = {...favorites};
    if (!favorites.add(id)) favorites.remove(id);
  });
}
