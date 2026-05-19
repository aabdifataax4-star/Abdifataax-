import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:lucide_icons/lucide_icons.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  runApp(const HealthCheckApp());
}

class HealthCheckApp extends StatelessWidget {
  const HealthCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'HealthCheck AI',
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2A5CFF),
              brightness: Brightness.light,
              surface: const Color(0xFFF4F7FE),
            ),
            scaffoldBackgroundColor: const Color(0xFFF4F7FE),
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Color(0xFF1A1C1E)),
              displayMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF1A1C1E)),
              headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 24, color: Color(0xFF1A1C1E)),
              titleMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Color(0xFF1A1C1E)),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2A5CFF),
              brightness: Brightness.dark,
              surface: const Color(0xFF0F172A),
            ),
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            textTheme: const TextTheme(
              displayLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.white),
              displayMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.white),
              headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 24, color: Colors.white),
              titleMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 18, color: Colors.white),
            ),
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// --- Auth Mock ---
class AuthService {
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString('user_$username');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      if (user['password'] == password) {
        await prefs.setString('currentUser', username);
        return true;
      }
    }
    return false;
  }

  static Future<bool> register(String fullName, String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final user = {'name': fullName, 'username': username, 'password': password};
    await prefs.setString('user_$username', jsonEncode(user));
    return true;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }

  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currentUser');
  }
}

// --- Screens ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 4));
    final currentUser = await AuthService.getCurrentUser();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => currentUser != null ? const MainContainer() : const RegisterScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(LucideIcons.activity, size: 64, color: Color(0xFF2A5CFF)),
            ),
            const SizedBox(height: 32),
            const Text(
              'HealthCheck AI', 
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your Intelligent Health Companion', 
              style: TextStyle(
                color: Colors.grey[600], 
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFF2A5CFF),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Main Container with Bottom Navigation ---

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const SymptomInputScreen(),
    const HistoryScreen(),
    const DoctorsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF2A5CFF),
            unselectedItemColor: Colors.grey[400],
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.activity), label: 'Check'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.history), label: 'History'),
              BottomNavigationBarItem(icon: Icon(LucideIcons.userPlus), label: 'Doctors'),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  _login() async {
    if (await AuthService.login(_usernameController.text, _passwordController.text)) {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainContainer()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid username or password.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF2A5CFF).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF2A5CFF).withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.activity, size: 40, color: Color(0xFF2A5CFF)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'HealthCheck AI',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  Text(
                    'Welcome Back', 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account', 
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: LucideIcons.user,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: LucideIcons.lock,
                    isPassword: true,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF2A5CFF))),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: const Color(0xFF2A5CFF),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New user? ", style: TextStyle(color: Colors.grey[600])),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                        child: const Text(
                          'Create Account', 
                          style: TextStyle(color: Color(0xFF2A5CFF), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1C1E))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF2A5CFF), size: 20),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter your $label',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2A5CFF), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  _register() async {
    if (await AuthService.register(_fullNameController.text, _usernameController.text, _passwordController.text)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Created! Please Sign In.')));
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Color(0xFF1A1C1E)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(LucideIcons.userPlus, size: 40, color: Color(0xFF6366F1)),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Join Us',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Create Account', 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join HealthCheck AI to manage your wellness.', 
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  _buildRegisterTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: LucideIcons.userCheck,
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 20),
                  _buildRegisterTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: LucideIcons.user,
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 20),
                  _buildRegisterTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: LucideIcons.lock,
                    isPassword: true,
                    color: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: TextStyle(color: Colors.grey[600])),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                        child: const Text(
                          'Sign In', 
                          style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1C1E))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color, size: 20),
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter your $label',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = "User";
  Timer? _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUser();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getFormattedTime() {
    int hour = _currentTime.hour;
    String minute = _currentTime.minute.toString().padLeft(2, '0');
    String second = _currentTime.second.toString().padLeft(2, '0');
    String period = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return "$hour:$minute:$second $period";
  }

  _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentUser');
    if (email != null) {
      final userJson = prefs.getString('user_$email');
      if (userJson != null) {
        if (mounted) {
          setState(() {
            _userName = jsonDecode(userJson)['name'];
          });
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Health Dashboard',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface, 
            fontWeight: FontWeight.bold
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            icon: const Icon(LucideIcons.logOut, color: Colors.redAccent),
          ),
          IconButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final bool isDark = themeNotifier.value == ThemeMode.dark;
              themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
              await prefs.setBool('isDarkMode', !isDark);
            },
            icon: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (_, ThemeMode mode, __) {
                return Icon(
                  mode == ThemeMode.dark ? LucideIcons.sun : LucideIcons.moon,
                  color: const Color(0xFF2A5CFF),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF2A5CFF).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.bell, color: Color(0xFF2A5CFF), size: 20),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E213A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $_userName', 
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(LucideIcons.mapPin, color: Color(0xFF00C9A7), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Hargeisa, Somaliland', 
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${_currentTime.day}/${_currentTime.month}/${_currentTime.year}', 
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFormattedTime(), 
                        style: const TextStyle(
                          color: Color(0xFF00C9A7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00C9A7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00C9A7).withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Health Services', 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16, 
                  color: Color(0xFF00C9A7),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: MediaQuery.of(context).size.width > 800 ? 1.6 : 1.3,
              children: [
                _DashboardCard(
                  icon: LucideIcons.activity,
                  title: 'Symptom Checker',
                  color: const Color(0xFF2A5CFF),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SymptomInputScreen())),
                ),
                _DashboardCard(
                  icon: LucideIcons.history,
                  title: 'View History',
                  color: const Color(0xFF6C63FF),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen())),
                ),
                _DashboardCard(
                  icon: LucideIcons.beaker,
                  title: 'Laboratory',
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LaboratoryScreen())),
                ),
                _DashboardCard(
                  icon: LucideIcons.plusSquare,
                  title: 'Pharmacy',
                  color: const Color(0xFF00C9A7),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PharmacyScreen())),
                ),
                _DashboardCard(
                  icon: LucideIcons.pill,
                  title: 'Medicines',
                  color: Colors.redAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicinesScreen())),
                ),
                _DashboardCard(
                  icon: LucideIcons.userPlus,
                  title: 'Doctors',
                  color: Colors.blueAccent,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DoctorsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Insights', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 20, 
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {}, 
                  child: const Text('See All', style: TextStyle(color: Color(0xFF2A5CFF))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InsightCard(
              title: 'Water Intake Tip',
              content: 'Drinking 8 glasses of water a day helps maintain energy levels.',
              icon: LucideIcons.droplets,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _InsightCard(
              title: 'Importance of Sleep',
              content: 'Consistent sleep improves the immune system and brain function.',
              icon: LucideIcons.moon,
              color: Colors.purple,
            ),
            const SizedBox(height: 32),
            Text(
              'Body Education', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 20, 
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SpecialtyItem(
                    imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Heart_normal.svg?width=400',
                    label: 'Heart', 
                    color: Colors.redAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganDetailScreen(organ: 'Heart'))),
                  ),
                  _SpecialtyItem(
                    imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Human_brain_NIH.jpg?width=400',
                    label: 'Brain', 
                    color: Colors.purpleAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganDetailScreen(organ: 'Brain'))),
                  ),
                  _SpecialtyItem(
                    imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Liver.svg?width=400',
                    label: 'Liver', 
                    color: Colors.orangeAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganDetailScreen(organ: 'Liver'))),
                  ),
                  _SpecialtyItem(
                    imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Lungs.svg?width=400',
                    label: 'Lungs', 
                    color: Colors.blueAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganDetailScreen(organ: 'Lungs'))),
                  ),
                  _SpecialtyItem(
                    imageUrl: 'https://commons.wikimedia.org/wiki/Special:FilePath/Kidney_cross_section.svg?width=400',
                    label: 'Kidneys', 
                    color: Colors.greenAccent,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrganDetailScreen(organ: 'Kidneys'))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 15, 
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _InsightCard({required this.title, required this.content, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15, 
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content, 
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyItem extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SpecialtyItem({this.icon, this.imageUrl, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(imageUrl != null ? 0 : 16),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl != null 
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label, 
              style: TextStyle(
                fontSize: 13, 
                fontWeight: FontWeight.w600, 
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Organ Detail Screen ---

class OrganDetailScreen extends StatelessWidget {
  final String organ;
  const OrganDetailScreen({super.key, required this.organ});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = {
      'Heart': {
        'icon': LucideIcons.heart,
        'color': Colors.redAccent,
        'desc': 'The heart is the engine of the body that distributes blood to all cells.',
        'tips': [
          'Exercise for at least 30 minutes a day.',
          'Reduce excess salt and fat.',
          'Avoid excessive stress.',
          'Eat fresh vegetables and fruits.'
        ]
      },
      'Brain': {
        'icon': LucideIcons.brain,
        'color': Colors.purpleAccent,
        'desc': 'The brain is the center that controls sensations, movement, and thinking.',
        'tips': [
          'Get better sleep (7-8 hours).',
          'Learn new things to stay active.',
          'Drink plenty of water.',
          'Avoid excessive screen use at night.'
        ]
      },
      'Liver': {
        'icon': LucideIcons.activity,
        'color': Colors.orangeAccent,
        'desc': 'The liver filters toxins from the blood and helps with digestion.',
        'tips': [
          'Avoid medications not prescribed by a doctor.',
          'Drink plenty of water to flush out toxins.',
          'Reduce excess sugar.',
          'Eat high-fiber foods.'
        ]
      },
      'Lungs': {
        'icon': LucideIcons.wind,
        'color': Colors.blueAccent,
        'desc': 'Lungs provide oxygen to the body and remove carbon dioxide.',
        'tips': [
          'Avoid cigarette smoke and air pollution.',
          'Practice deep breathing exercises.',
          'Maintain cleanliness in your environment.',
          'Eat foods rich in Antioxidants.'
        ]
      },
      'Kidneys': {
        'icon': LucideIcons.database,
        'color': Colors.greenAccent,
        'desc': 'Kidneys filter waste from the blood and balance body fluids.',
        'tips': [
          'Drink enough water throughout the day.',
          'Reduce salt intake.',
          'Monitor your blood pressure.',
          'Avoid excessive use of painkillers.'
        ]
      },
    };

    final organData = data[organ] ?? data['Wadnaha'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Education: $organ'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: organData['color'].withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(organData['icon'], color: organData['color'], size: 80),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'What to know about $organ?', 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 16),
            Text(
              organData['desc'], 
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 40),
            Text(
              'Health Tips:', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: organData['color']),
            ),
            const SizedBox(height: 16),
            ... (organData['tips'] as List).map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.checkCircle2, color: organData['color'], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip, 
                        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

// --- Rest of the screens (SymptomInput, AnalysisResult, History) updated ---

class SymptomInputScreen extends StatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  State<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends State<SymptomInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _allSymptoms = [
    // General / Systemic
    'Fever', 'Fatigue', 'Chills', 'Sweating', 'Unexplained Weight Loss', 'Unexplained Weight Gain', 'Loss of Appetite',
    // Head & Neck
    'Headache', 'Dizziness', 'Sore Throat', 'Congestion', 'Runny Nose', 'Loss of Smell', 'Loss of Taste', 'Vision Changes', 'Difficulty Swallowing',
    // Respiratory
    'Cough', 'Shortness of Breath', 'Wheezing', 'Coughing up Blood',
    // Cardiovascular
    'Chest Pain', 'Palpitations', 'Swelling in Legs/Ankles',
    // Gastrointestinal
    'Nausea', 'Vomiting', 'Abdominal Pain', 'Diarrhea', 'Constipation', 'Bloody Stool', 'Jaundice',
    // Musculoskeletal
    'Muscle Pain', 'Joint Pain', 'Back Pain', 'Bone Pain',
    // Neurological
    'Numbness or Tingling', 'Confusion', 'Memory Loss', 'Seizures',
    // Dermatological
    'Rash', 'Itching', 'Skin Discoloration',
    // Urological
    'Frequent Urination', 'Painful Urination', 'Blood in Urine'
  ];
  List<String> _filteredSymptoms = [];
  final List<String> _selectedSymptoms = [];

  void _onSearch(String query) {
    setState(() {
      _filteredSymptoms = _allSymptoms
          .where((s) => s.toLowerCase().contains(query.toLowerCase()) && !_selectedSymptoms.contains(s))
          .toList();
    });
  }

  void _addSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.add(symptom);
      _controller.clear();
      _filteredSymptoms.clear();
    });
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
    });
  }

  void _analyzeSymptoms() {
    if (_selectedSymptoms.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultScreen(symptoms: _selectedSymptoms),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Symptom Checker', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How are you feeling today?', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Search symptoms (e.g. Fever, Cough)',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(LucideIcons.search, color: Color(0xFF2A5CFF)),
                suffixIcon: _controller.text.isNotEmpty 
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _filteredSymptoms.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2A5CFF), width: 2),
                ),
              ),
            ),
            if (_filteredSymptoms.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSymptoms.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredSymptoms[index]),
                      trailing: const Icon(LucideIcons.plus, size: 18, color: Color(0xFF2A5CFF)),
                      onTap: () => _addSymptom(_filteredSymptoms[index]),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Selected Symptoms:', 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedSymptoms.map((s) => Chip(
                label: Text(s),
                onDeleted: () => _removeSymptom(s),
                deleteIcon: const Icon(LucideIcons.x, size: 14),
                backgroundColor: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedSymptoms.isEmpty ? null : _analyzeSymptoms,
                icon: const Icon(LucideIcons.sparkles),
                label: const Text('Analyze Symptoms'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF2A5CFF),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisResultScreen extends StatefulWidget {
  final List<String> symptoms;
  const AnalysisResultScreen({super.key, required this.symptoms});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();
    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    await Future.delayed(const Duration(seconds: 2));
    
    String risk = 'Low';
    List<String> conditions = [];
    List<String> advice = [];
    String recommendation = '';

    // Check for specific critical red flags
    bool hasChestPain = widget.symptoms.contains('Chest Pain');
    bool hasShortnessOfBreath = widget.symptoms.contains('Shortness of Breath');
    bool hasConfusion = widget.symptoms.contains('Confusion');
    bool hasCoughingBlood = widget.symptoms.contains('Coughing up Blood');
    bool hasSeizures = widget.symptoms.contains('Seizures');
    
    // Check for moderate/systemic symptoms
    bool hasFever = widget.symptoms.contains('Fever');
    bool hasCough = widget.symptoms.contains('Cough');
    bool hasLossOfSmellTaste = widget.symptoms.contains('Loss of Smell') || widget.symptoms.contains('Loss of Taste');
    bool hasAbdominalPain = widget.symptoms.contains('Abdominal Pain');
    bool hasVomiting = widget.symptoms.contains('Vomiting');
    bool hasDiarrhea = widget.symptoms.contains('Diarrhea');
    bool hasHeadache = widget.symptoms.contains('Headache');
    bool hasFatigue = widget.symptoms.contains('Fatigue');

    // CRITICAL RISK
    if (hasChestPain || hasShortnessOfBreath || hasConfusion || hasCoughingBlood || hasSeizures) {
      risk = 'Critical';
      recommendation = 'IMMEDIATE ACTION REQUIRED: Please call emergency services (911) or visit the nearest Emergency Room immediately.';
      advice.addAll(['Remain calm and seated', 'Loosen tight clothing', 'Do not drive yourself to the hospital']);
      
      if (hasChestPain) conditions.add('Potential Cardiac Event (Heart Attack)');
      if (hasShortnessOfBreath) conditions.add('Severe Respiratory Distress');
      if (hasConfusion || hasSeizures) conditions.add('Neurological Emergency');
      if (hasCoughingBlood) conditions.add('Severe Pulmonary Issue');
    } 
    // HIGH RISK
    else if (hasFever && hasLossOfSmellTaste && hasCough) {
      risk = 'High';
      recommendation = 'Urgent medical consultation advised. Isolate to prevent spread.';
      conditions.add('COVID-19 or Severe Influenza');
      advice.addAll(['Isolate from others immediately', 'Wear a mask', 'Monitor oxygen levels', 'Stay hydrated']);
    }
    else if (hasAbdominalPain && (hasVomiting || hasDiarrhea)) {
      risk = 'Moderate';
      recommendation = 'Seek medical evaluation if symptoms worsen or you cannot keep fluids down for 24 hours.';
      conditions.add('Gastroenteritis (Stomach Flu) or Food Poisoning');
      advice.addAll(['Sip clear fluids slowly to prevent dehydration', 'Avoid solid foods until vomiting stops', 'Rest completely']);
    }
    // MODERATE RISK combinations
    else if (hasFever && hasCough) {
      risk = 'Moderate';
      recommendation = 'Monitor symptoms. If breathing becomes difficult or fever persists for 3 days, see a doctor.';
      conditions.add('Bronchitis or Viral Infection');
      advice.addAll(['Rest and drink plenty of fluids', 'Use cough drops or honey for throat', 'Monitor temperature']);
    }
    else if (hasFever && hasHeadache) {
      risk = 'Moderate';
      recommendation = 'Rest and monitor. If neck stiffness or light sensitivity occurs, seek urgent care.';
      conditions.add('Viral Infection or Influenza');
      advice.addAll(['Take antipyretics (e.g., Paracetamol) for fever', 'Rest in a quiet room', 'Stay hydrated']);
    }
    // LOW / INDIVIDUAL SYMPTOMS
    else {
      risk = 'Low';
      recommendation = 'Self-care at home. If symptoms persist beyond a few days, consult a healthcare provider.';
      
      if (hasHeadache) {
        conditions.add('Tension Headache or Migraine');
        advice.addAll(['Rest in a dark, quiet environment', 'Avoid screen time', 'Apply a cold compress to the forehead', 'Stay hydrated']);
      }
      if (hasFever) {
        conditions.add('Mild Viral Infection');
        advice.addAll(['Take fever-reducing medication (e.g., Paracetamol)', 'Wear light clothing', 'Drink plenty of water']);
      }
      if (hasCough) {
        conditions.add('Upper Respiratory Tract Infection');
        advice.addAll(['Use a humidifier or inhale steam', 'Gargle with warm salt water', 'Avoid cold drinks']);
      }
      if (hasFatigue) {
        conditions.add('Physical or Mental Exhaustion');
        advice.addAll(['Ensure 7-8 hours of restful sleep', 'Maintain a balanced diet', 'Reduce stress levels']);
      }
      if (widget.symptoms.contains('Muscle Pain') || widget.symptoms.contains('Joint Pain')) {
        conditions.add('Musculoskeletal Strain');
        advice.addAll(['Apply ice to affected areas initially, then heat', 'Rest the affected muscles', 'Consider gentle stretching']);
      }
      
      // Fallback if none of the specific ones were matched
      if (conditions.isEmpty) {
        conditions.add('General Discomfort or Mild Infection');
        advice.addAll(['Get plenty of rest', 'Monitor your symptoms closely', 'Stay well hydrated']);
      }
    }

    final result = {
      'risk': risk,
      'conditions': conditions,
      'advice': advice,
      'recommendation': recommendation,
      'timestamp': DateTime.now().toIso8601String(),
      'symptoms': widget.symptoms,
    };

    setState(() {
      _analysis = result;
      _isLoading = false;
    });

    _saveToHistory(result);
  }

  Future<void> _saveToHistory(Map<String, dynamic> result) async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('history');
    List<dynamic> history = historyString != null ? jsonDecode(historyString) : [];
    history.insert(0, result);
    await prefs.setString('history', jsonEncode(history));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Analysis Result', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF2A5CFF)),
              SizedBox(height: 24),
              Text('AI is analyzing symptoms...', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getRiskColor(_analysis!['risk']).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getRiskIcon(_analysis!['risk']), 
                          color: _getRiskColor(_analysis!['risk']),
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Risk Level: ${_analysis!['risk']}', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 22,
                          color: _getRiskColor(_analysis!['risk']),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on your reported symptoms.', 
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                _ResultSection(
                  title: 'Possible Conditions',
                  icon: LucideIcons.shieldAlert,
                  color: Colors.orange,
                  items: List<String>.from(_analysis!['conditions']),
                ),
                const SizedBox(height: 24),
                _ResultSection(
                  title: 'Self-Care Advice',
                  icon: LucideIcons.heartPulse,
                  color: const Color(0xFF00C9A7),
                  items: List<String>.from(_analysis!['advice']),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A5CFF),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.stethoscope, size: 24, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'AI Recommendation', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _analysis!['recommendation'], 
                        style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Critical': return Colors.red;
      case 'High': return Colors.orange;
      case 'Moderate': return Colors.blue;
      default: return Colors.green;
    }
  }

  IconData _getRiskIcon(String risk) {
    switch (risk) {
      case 'Critical': return LucideIcons.alertOctagon;
      case 'High': return LucideIcons.alertTriangle;
      case 'Moderate': return LucideIcons.info;
      default: return LucideIcons.checkCircle;
    }
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _ResultSection({required this.title, required this.icon, required this.color, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(item, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.4))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyString = prefs.getString('history');
    if (historyString != null) {
      setState(() {
        _history = jsonDecode(historyString);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Checkup History', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _history.isEmpty 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.history, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('No history found.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[index];
              final date = DateTime.parse(item['timestamp']);
              final riskColor = _getRiskColor(item['risk']);
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.activity, color: riskColor, size: 24),
                  ),
                  title: Text(
                    (item['symptoms'] as List).join(', '), 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Risk: ${item['risk']} • ${date.day}/${date.month}/${date.year}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                  trailing: Icon(LucideIcons.chevronRight, color: Colors.grey[400]),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AnalysisResultScreen(symptoms: List<String>.from(item['symptoms']))));
                  },
                ),
              );
            },
          ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'Critical': return Colors.red;
      case 'High': return Colors.orange;
      case 'Moderate': return Colors.blue;
      default: return Colors.green;
    }
  }
}
// --- Laboratory Screen ---

class LaboratoryScreen extends StatelessWidget {
  const LaboratoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tests = [
      {'name': 'Complete Blood Count (CBC)', 'desc': 'Measures red and white blood cells, hemoglobin, and platelets.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Venipuncture_using_a_Vacutainer.jpg?width=400'},
      {'name': 'Lipid Profile', 'desc': 'Checks cholesterol and fat levels to assess heart health.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Blood_vials.jpg?width=400'},
      {'name': 'Blood Sugar Test', 'desc': 'Measures the amount of sugar in your blood to screen for diabetes.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Blood_glucose_testing.JPG?width=400'},
      {'name': 'Liver Function Test', 'desc': 'Evaluates your liver health by measuring proteins and enzymes.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Liver.svg?width=400'},
      {'name': 'Kidney Function Test', 'desc': 'Evaluates how well your kidneys are filtering waste from the blood.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Kidney_cross_section.svg?width=400'},
      {'name': 'MRI Scan', 'desc': 'Uses magnetic fields to create detailed images of body organs.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Modern_3T_MRI_scanner.jpg?width=400'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Laboratory Tests', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tests.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(color: Colors.white),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: tests[index]['image'] != null
                                ? (tests[index]['isAsset'] as dynamic == true
                                    ? Image.asset(tests[index]['image'] as String, fit: BoxFit.cover)
                                    : Image.network(tests[index]['image'] as String, fit: BoxFit.cover))
                                : const Icon(LucideIcons.beaker, color: Colors.orange, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tests[index]['name'] as String, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1A1C1E)),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Laboratory Result: 24-48h', 
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tests[index]['desc'] as String, 
                        style: TextStyle(color: Colors.grey[600], height: 1.5, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.tag, size: 14, color: Color(0xFF2A5CFF)),
                              SizedBox(width: 6),
                              Text(
                                'Certified Lab',
                                style: TextStyle(color: Color(0xFF2A5CFF), fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Requested successfully!'))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A5CFF),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Color(0xFF2A5CFF).withValues(alpha: 0.2),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Book Test', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- Pharmacy Screen ---

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  final List<Map<String, String>> _items = [
    {'name': 'Paracetamol', 'price': '\$5.00', 'desc': 'Pain reliever and fever reducer.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Paracetamol-blister.jpg?width=400'},
    {'name': 'Amoxicillin', 'price': '\$12.00', 'desc': 'Antibiotic for various infections.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Amoxicillin_500mg_capsules_on_a_plate_(Sandoz).jpg?width=400'},
    {'name': 'Vitamin C', 'price': '\$8.50', 'desc': 'Supplement for immune system support.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Vitamin_C_pills.jpg?width=400'},
    {'name': 'Cough Syrup', 'price': '\$7.00', 'desc': 'Soothes cough and sore throat.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Cough_syrup.jpg?width=400'},
    {'name': 'Antiseptic Cream', 'price': '\$4.00', 'desc': 'Prevents infection in minor wounds.', 'image': 'https://commons.wikimedia.org/wiki/Special:FilePath/Ointment.jpg?width=400'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Pharmacy Store', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(LucideIcons.search, color: Color(0xFF2A5CFF)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03), 
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF00C9A7).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _items[index]['image'] != null
                              ? Image.network(_items[index]['image']!, fit: BoxFit.cover)
                              : const Icon(LucideIcons.package, color: Color(0xFF00C9A7), size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _items[index]['name']!, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A1C1E)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _items[index]['desc']!, 
                                style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    _items[index]['price']!, 
                                    style: const TextStyle(
                                      color: Color(0xFF00C9A7), 
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 18,
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () => _showOrderForm(context, _items[index]['name']!),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                                      foregroundColor: const Color(0xFF2A5CFF),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('Order', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderForm(BuildContext context, String medicineName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(32, 24, 32, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.shoppingCart, color: Color(0xFF2A5CFF), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Complete Your Order', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                      Text(medicineName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1E))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildOrderTextField(LucideIcons.hash, 'Quantity', 'e.g. 1 packet'),
            const SizedBox(height: 16),
            _buildOrderTextField(LucideIcons.mapPin, 'Delivery Address', 'Enter your full address'),
            const SizedBox(height: 16),
            _buildOrderTextField(LucideIcons.phone, 'Phone Number', '+252 ...'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Your order has been placed successfully!'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: const Color(0xFF00C9A7),
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: const Color(0xFF2A5CFF),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Confirm & Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTextField(IconData icon, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1A1C1E))),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2A5CFF), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Medicines Screen ---

class MedicinesScreen extends StatelessWidget {
  const MedicinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final medicines = [
      {'name': 'Aspirin', 'use': 'Pain, fever, inflammation', 'dosage': '300-600mg every 4-6 hours'},
      {'name': 'Ibuprofen', 'use': 'Pain, fever, inflammation', 'dosage': '200-400mg every 4-6 hours'},
      {'name': 'Cetirizine', 'use': 'Allergies', 'dosage': '10mg once daily'},
      {'name': 'Metformin', 'use': 'Type 2 Diabetes', 'dosage': '500-1000mg twice daily'},
      {'name': 'Atorvastatin', 'use': 'High cholesterol', 'dosage': '10-80mg once daily'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Medicines List', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: medicines.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03), 
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                iconColor: const Color(0xFF2A5CFF),
                collapsedIconColor: Colors.grey[400],
                tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(LucideIcons.pill, color: Colors.redAccent, size: 24),
                ),
                title: Text(
                  medicines[index]['name']!, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A1C1E)),
                ),
                subtitle: Text(
                  'Quick Reference Guide', 
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Color(0xFFF4F7FE), height: 1),
                        const SizedBox(height: 20),
                        _buildMedicineDetail(LucideIcons.activity, 'Usage', medicines[index]['use']!),
                        const SizedBox(height: 16),
                        _buildMedicineDetail(LucideIcons.clock, 'Recommended Dosage', medicines[index]['dosage']!),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2A5CFF)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Full Prescribing Info', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2A5CFF))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMedicineDetail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1C1E))),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Doctors Screen ---

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  String _selectedSpecialty = 'All';

  final List<Map<String, String>> _allDoctors = [
    {'name': 'Dr. Ahmed Mohamud', 'specialty': 'Cardiologist', 'exp': '15 Years', 'rating': '4.9', 'loc': 'Hargeisa'},
    {'name': 'Dr. Hodan Ali', 'specialty': 'Pediatrician', 'exp': '10 Years', 'rating': '4.8', 'loc': 'Hargeisa'},
    {'name': 'Dr. Faisal Omer', 'specialty': 'Neurologist', 'exp': '12 Years', 'rating': '4.7', 'loc': 'Hargeisa'},
    {'name': 'Dr. Amina Yusuf', 'specialty': 'Gynecologist', 'exp': '9 Years', 'rating': '5.0', 'loc': 'Hargeisa'},
    {'name': 'Dr. Mustafa Ismail', 'specialty': 'Orthopedic', 'exp': '14 Years', 'rating': '4.8', 'loc': 'Hargeisa'},
    {'name': 'Dr. Khadra Abdi', 'specialty': 'Dermatologist', 'exp': '7 Years', 'rating': '4.6', 'loc': 'Hargeisa'},
    {'name': 'Dr. Sahra Jama', 'specialty': 'Dentist', 'exp': '8 Years', 'rating': '4.9', 'loc': 'Hargeisa'},
    {'name': 'Dr. Osman Duale', 'specialty': 'Cardiologist', 'exp': '20 Years', 'rating': '5.0', 'loc': 'Hargeisa'},
  ];

  final List<String> _categories = [
    'All', 'Cardiologist', 'Pediatrician', 'Neurologist', 'Gynecologist', 'Orthopedic', 'Dermatologist', 'Dentist'
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = _selectedSpecialty == 'All'
        ? _allDoctors
        : _allDoctors.where((d) => d['specialty'] == _selectedSpecialty).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      appBar: AppBar(
        title: const Text('Find a Specialist', style: TextStyle(color: Color(0xFF1A1C1E), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 70,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedSpecialty == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSpecialty = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2A5CFF) : const Color(0xFFF4F7FE),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Color(0xFF2A5CFF).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Icon(LucideIcons.user, color: Color(0xFF2A5CFF), size: 32),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filteredDoctors[index]['name']!, 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1A1C1E)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${filteredDoctors[index]['specialty']!} • ${filteredDoctors[index]['loc']!}', 
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(LucideIcons.star, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    filteredDoctors[index]['rating']!, 
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(LucideIcons.briefcase, size: 14, color: Color(0xFF00C9A7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${filteredDoctors[index]['exp']!} exp', 
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appointment booked!'))),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2A5CFF).withValues(alpha: 0.1),
                            foregroundColor: const Color(0xFF2A5CFF),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
