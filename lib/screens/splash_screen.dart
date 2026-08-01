import 'package:flutter/material.dart';
import 'package:food_order_ui/screens/login_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 4),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6B81),
              Color(0xFFFF4757),
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(),

            Text(
              "FoodGo",
              style: GoogleFonts.pacifico(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),

            const Spacer(),

            SizedBox(
              height: 320,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 0,
                    top: 60,
                    child: Image.asset(
                      "assets/Transpizza.png",
                      height: 240,
                      errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 2,
                    child: Image.asset(
                      "assets/Transtaco.png",
                      height: 190,
                      errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                    ),
                  ),
                  Image.asset(
                    "assets/burger.png",
                    height: 200,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.fastfood, size: 100, color: Colors.white),
                  ),
                ],
              ),
            ),

            Text(
              "Order Your favourite Food",
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            Text(
              "Fast Delivery & Fresh Food",
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF4757),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: () {
                    // pushReplacement ব্যবহার করলে ইউজার ব্যাক বাটনে চাপলে আবার স্প্ল্যাশ স্ক্রিনে আসবে না
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}