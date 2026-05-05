import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Базовий метод входу
  Future<String?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      String uid = userCredential.user!.uid;
      
      // Перевірка ролі (Студент чи Замовник)
      DocumentSnapshot studentDoc = await _firestore.collection('students').doc(uid).get();
      if (studentDoc.exists) return 'student';
      
      DocumentSnapshot employerDoc = await _firestore.collection('employers').doc(uid).get();
      if (employerDoc.exists) return 'employer';
      
      return null;
    } catch (e) {
      return 'Помилка: Невірний email або пароль';
    }
  }

  Future<void> registerStudent(String em, String p) async {
    // TODO: додати валідацію пароля пізніше
    
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: em,
      password: p,
    );
    
    // Збереження додаткових даних у Firestore
    await _firestore.collection('students').doc(cred.user!.uid).set({
      'email': em,
      'registration_date': FieldValue.serverTimestamp(),
      'is_verified': false,
      // інші поля заповнюються з UI
    });
  }
}
