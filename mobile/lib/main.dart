import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseUrl = 'https://lm-dating-backend.onrender.com';

void main() {
  runApp(const LMDatingApp());
}

Map<String, dynamic>? currentUser;

class LMDatingApp extends StatelessWidget {
  const LMDatingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'L.M Знакомства',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF4081),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF4081),
          secondary: Color(0xFF1E1E1E),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// 1. Экран Приветствия
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A0845), Color(0xFF0F0F0F)],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Icon(Icons.favorite, size: 90, color: Color(0xFFFF4081)),
            const SizedBox(height: 20),
            const Text(
              'L.M Знакомства',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'Найдите свою любовь, друзей и интересное общение рядом с вами',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4081),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Войти в аккаунт', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFF4081)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Создать профиль', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 2. Экран Авторизации
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  bool isLoading = false;

  void login() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': _nameController.text.trim(), 'password': _passController.text}),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        currentUser = data['user'];
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Неверное имя или пароль')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка соединения: $e')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Ваше имя', border: OutlineInputBorder())),
            const SizedBox(height: 15),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder())),
            const SizedBox(height: 25),
            isLoading
                ? const CircularProgressIndicator(color: Color(0xFFFF4081))
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4081)),
                      onPressed: login,
                      child: const Text('Войти', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// 3. Экран Регистрации
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();
  final _passController = TextEditingController();
  String gender = 'male';
  bool isLoading = false;

  void register() async {
    setState(() => isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text.trim(),
          'age': int.tryParse(_ageController.text) ?? 18,
          'city': _cityController.text.trim(),
          'bio': _bioController.text.trim(),
          'gender': gender,
          'password': _passController.text,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Регистрация успешна! Войдите в аккаунт.')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ошибка регистрации (возможно, имя занято)')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, title: const Text('Регистрация анкеты')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Возраст', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _cityController, decoration: const InputDecoration(labelText: 'Город', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'О себе', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder())),
          const SizedBox(height: 25),
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4081), padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: register,
                  child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
        ],
      ),
    );
  }
}

// 4. Главная навигация внутри приложения
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const RadarScreen(),
    const ChatsListScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFFF4081),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Радар & Поиск'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Сообщения'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}

// 5. Радар и Поиск людей
class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    try {
      final myId = currentUser?['id'] ?? 0;
      final response = await http.get(Uri.parse('$baseUrl/api/users/radar?exclude_id=$myId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data['users'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Люди рядом (${currentUser?['city'] ?? ''})'), backgroundColor: const Color(0xFF1E1E1E)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF4081)))
          : users.isEmpty
              ? const Center(child: Text('Пока никого нет поблизости'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.only(bottom: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 30, backgroundColor: Color(0xFFFF4081), child: Icon(Icons.person, size: 35, color: Colors.white)),
                                const SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${user['name']}, ${user['age']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    Text('${user['city']} • ${user['distance']}', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(user['bio'], style: const TextStyle(fontSize: 15)),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF4081)),
                                icon: const Icon(Icons.chat, color: Colors.white),
                                label: const Text('Написать сообщение', style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChatScreen(partner: user)),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// 6. Список чатов
class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ваши Чаты 💬'), backgroundColor: const Color(0xFF1E1E1E)),
      body: const Center(
        child: Text('Выберите человека на вкладке "Радар", чтобы начать общение!', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// 7. Экран обмена сообщениями
class ChatScreen extends StatefulWidget {
  final Map partner;
  const ChatScreen({super.key, required this.partner});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  final _msgController = TextEditingController();

  void sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/api/messages/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_id': currentUser!['id'],
          'receiver_id': widget.partner['id'],
          'text': _msgController.text.trim(),
        }),
      );
      _msgController.clear();
      fetchMessages();
    } catch (e) {
      // ошибка
    }
  }

  void fetchMessages() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/messages/history?user1=${currentUser!['id']}&user2=${widget.partner['id']}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => messages = data['messages']);
      }
    } catch (e) {
      // ошибка
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.partner['name']), backgroundColor: const Color(0xFF1E1E1E)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg['sender_id'] == currentUser!['id'];
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFFFF4081) : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg['text'], style: const TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'Введите сообщение...', border: InputBorder.none),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send, color: Color(0xFFFF4081)), onPressed: sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 8. Профиль пользователя
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мой Профиль'), backgroundColor: const Color(0xFF1E1E1E)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Color(0xFFFF4081), child: Icon(Icons.person, size: 60, color: Colors.white)),
            const SizedBox(height: 15),
            Text(currentUser?['name'] ?? 'Имя', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text('${currentUser?['city']}, ${currentUser?['age']} лет', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            Text(currentUser?['bio'] ?? '', style: const TextStyle(fontStyle: FontStyle.italic)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              onPressed: () {
                currentUser = null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                );
              },
              child: const Text('Выйти из аккаунта', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}