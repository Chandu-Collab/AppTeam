import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:taurusai/screens/login_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define pages with descriptive text for each feature and white text styling.
    final List<PageViewModel> pages = [
      PageViewModel(
        title: "Login",
        body:
            "Log in securely to unlock your professional journey. Access personalized dashboards, job alerts, and network insights—just like the real LinkedIn experience.",
        image: const Center(
          child: Icon(Icons.login, size: 100.0, color: Colors.blue),
        ),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      PageViewModel(
        title: "Sign Up",
        body:
            "Create your account in minutes and join our vibrant professional community. Experience a seamless onboarding process in Taurusai.",
        image: const Center(
          child: Icon(Icons.person_add, size: 100.0, color: Colors.orange),
        ),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      PageViewModel(
        title: "Home",
        body:
            "Explore a personalized dashboard that brings together news, updates, and career insights. Stay informed and inspired every day, much like on LinkedIn.",
        image: const Center(
          child: Icon(Icons.home, size: 100.0, color: Colors.green),
        ),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      PageViewModel(
        title: "Jobs",
        body:
            "Browse and apply for thousands of job opportunities tailored to your career goals. Our platform offers a job search experience similar to LinkedIn.",
        image: const Center(
          child: Icon(Icons.work, size: 100.0, color: Colors.purple),
        ),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      PageViewModel(
        title: "Post",
        body:
            "Share your professional updates, articles, and ideas with a dynamic community. Build your personal brand and engage with others on Taurusai.",
        image: const Center(
          child: Icon(Icons.post_add, size: 100.0, color: Colors.red),
        ),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      PageViewModel(
        title: "Courses",
        body:
            "Enhance your skills with expert-curated courses and tutorials. Stay competitive in your field with continuous learning on Taurusai Learning.",
        image: const Center(
          child: Icon(Icons.school, size: 100.0, color: Colors.teal),
        ),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
      PageViewModel(
        title: "Network",
        body:
            "Expand your professional network by connecting with industry leaders and peers. Unlock new opportunities in a true Taurusai environment.",
        image: const Center(
          child: Icon(Icons.contacts, size: 100.0, color: Colors.indigo),
        ),
        decoration: const PageDecoration(
          pageColor: Colors.transparent,
          titleTextStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          bodyTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Background image layer
          Positioned.fill(
            child: Image.asset(
              'images/v796_nunny_02.jpg', // Ensure this image is registered in pubspec.yaml
              fit: BoxFit.cover,
            ),
          ),
          // Introduction screen on top with a transparent background.
          IntroductionScreen(
            globalBackgroundColor: Colors.transparent,
            pages: pages,
            onDone: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            showSkipButton: true,
            skip: const Text("Skip",
                style: TextStyle(fontSize: 16, color: Colors.white)),
            next: const Icon(Icons.arrow_forward, color: Colors.white),
            done: const Text(
              "Done",
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
            ),
            dotsDecorator: DotsDecorator(
              size: const Size(10, 10),
              activeSize: const Size(22, 10),
              activeColor: Theme.of(context).primaryColor,
              color: Colors.white70,
              spacing: const EdgeInsets.symmetric(horizontal: 3),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
