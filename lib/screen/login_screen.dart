import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:in_app_notification/in_app_notification.dart';
import 'package:vansales/api/api.dart';
import 'package:vansales/screen/main_screen.dart';
import 'package:vansales/screen/profile_setup_screen.dart';
import 'package:vansales/utils.dart';
import 'package:vansales/widgets/NotificationBody.dart';

enum MobileVerificationState { SHOW_MOBILE_FORM_STATE, SHOW_OTP_FORM_STATE }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late MobileVerificationState currentState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  final phone = TextEditingController();
  final otp1 = TextEditingController();
  final otp2 = TextEditingController();
  final otp3 = TextEditingController();
  final otp4 = TextEditingController();
  final otp5 = TextEditingController();
  final otp6 = TextEditingController();
  late String otp = '';
  //late bool _isCorrect = false;
  late bool _isSending = false;
  late bool _isVerifing = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String verificationId;

  bool _isExisting = false;

  @override
  void initState() {
    //_isCorrect = false;
    _isSending = false;
    super.initState();
  }

  void isExisting(String phoneno) async {
    try {
      final endPointUri = Uri.parse(apiRootAddress + "/user/is/exist/$phoneno");
      final response = await get(endPointUri);
      print(response.statusCode);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _auth.verifyPhoneNumber(
          phoneNumber: phone.text,
          verificationCompleted: (phoneAuthCredential) async {
            setState(() {
              _isSending = false;
            });
            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          verificationFailed: (verificationFailed) async {
            setState(() {
              _isSending = false;
            });
            InAppNotification.show(
                child: NotificationBody(
                  title: 'Failed',
                  body: verificationFailed.message,
                  isError: true,
                ),
                context: context,
                duration: const Duration(seconds: 2),
                curve: Curves.decelerate);
          },
          codeSent: (verificationId, resendingToken) async {
            setState(() {
              _isSending = false;
              currentState = MobileVerificationState.SHOW_OTP_FORM_STATE;
              this.verificationId = verificationId;
            });
          },
          codeAutoRetrievalTimeout: (verificationId) async {},
        );

        final dataa = jsonDecode(response.body);
        print("${dataa['id']}");
        await Preferences.setUserId(dataa['id']);
        print(Preferences.getUserId());
        if (dataa['companyNameInArabic'] != null) {
          await Preferences.setPData(true);
          setState(() {
            _isExisting = true;
          });
        }
      } else if (response.statusCode == 409) {
        setState(() {
          _isExisting = false;
          _isSending = false;
        });
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              body:
                  "Your phone number is blocked, please contact the administrator",
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 4),
            curve: Curves.decelerate);
      } else {
        setState(() {
          _isExisting = false;
          _isSending = false;
        });
        InAppNotification.show(
            child: NotificationBody(
              title: 'Failed',
              body: "You are not authorized to use this app",
              isError: true,
            ),
            context: context,
            duration: const Duration(seconds: 4),
            curve: Curves.decelerate);
      }
    } on Exception catch (e) {
      print(e);
      InAppNotification.show(
          child: NotificationBody(
            title: 'Error',
            body: "Can't connect to the Database",
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 4),
          curve: Curves.decelerate);
      //Future.delayed(const Duration(seconds: 5), isExisting);
    }
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      _isVerifing = true;
    });
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        _isVerifing = false;
      });

      if (authCredential.user != null) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => _isExisting
                    ? const MainScreen()
                    : const ProfileSetupScreen(
                        isUpdate: false,
                      )));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isVerifing = false;
      });
      InAppNotification.show(
          child: NotificationBody(
            title: 'Failed',
            body: e.message,
            isError: true,
          ),
          context: context,
          duration: const Duration(seconds: 6),
          curve: Curves.decelerate);
    }
  }

  getMobileFormWidget(context) {
    return Column(
      children: [
        // Align(
        //   alignment: Alignment.topLeft,
        //   child: GestureDetector(
        //     onTap: () => Navigator.pop(context),
        //     child: Icon(
        //       Icons.arrow_back,
        //       size: 32,
        //       color: Colors.black54,
        //     ),
        //   ),
        // ),
        const SizedBox(
          height: 50,
        ),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            //color: Colors.indigo.shade50,
            color: Colors.indigoAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/images/login1.png',
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        const Text(
          'Registration',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Enter your phone number along with the country code. we'll send you a verification code so we know you're real",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 18,
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.phone,
                controller: phone,
                onChanged: (i) {
                  // if (i.length == 10) {
                  //   setState(() {
                  //     _isCorrect = true;
                  //   });
                  // } else {
                  //   setState(() {
                  //     _isCorrect = false;
                  //   });
                  // }
                },
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10)),
                  // prefix: const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 8),
                  //   child: Text(
                  //     '(+91)',
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  // suffixIcon: _isCorrect
                  //     ? const Icon(
                  //         Icons.check_circle,
                  //         color: Colors.green,
                  //         size: 32,
                  //       )
                  //     : null,
                ),
              ),
              const SizedBox(
                height: 22,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // if (_isCorrect) {
                    if (_isSending) {
                    } else {
                      setState(() {
                        _isSending = true;
                      });

                      isExisting(phone.text);
                    }
                    // } else {
                    //   InAppNotification.show(
                    //       child: NotificationBody(
                    //         title: 'Failed',
                    //         body: 'Enter a valid number',
                    //         isError: true,
                    //       ),
                    //       context: context,
                    //       duration: const Duration(seconds: 2),
                    //       curve: Curves.decelerate);
                    // }
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.indigoAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      // _isCorrect ?
                      _isSending
                          ? 'Sending'
                          // : 'Send'
                          : 'Send',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  getOtpFormWidget(context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: () => setState(() {
              currentState = MobileVerificationState.SHOW_MOBILE_FORM_STATE;
            }),
            child: const Icon(
              Icons.arrow_back,
              size: 32,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.indigoAccent.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/images/login2.png',
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        const Text(
          'Verification',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          "Enter your OTP code number",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 28,
        ),
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _textFieldOTP(first: true, last: false, controller: otp1),
                  _textFieldOTP(first: false, last: false, controller: otp2),
                  _textFieldOTP(first: false, last: false, controller: otp3),
                  _textFieldOTP(first: false, last: false, controller: otp4),
                  _textFieldOTP(first: false, last: false, controller: otp5),
                  _textFieldOTP(first: false, last: true, controller: otp6),
                ],
              ),
              const SizedBox(
                height: 22,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    otp = '';
                    otp = otp1.text +
                        otp2.text +
                        otp3.text +
                        otp4.text +
                        otp5.text +
                        otp6.text;
                    PhoneAuthCredential phoneAuthCredential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: otp);

                    signInWithPhoneAuthCredential(phoneAuthCredential);
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.indigoAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      _isVerifing ? 'Verifing' : 'Verify',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        const Text(
          "Didn't you receive any code?",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 18,
        ),
        InkWell(
          onTap: () {
            /// ToDo
          },
          child: const Text(
            "Resend New Code",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _textFieldOTP(
      {bool? first, last, required TextEditingController controller}) {
    return SizedBox(
      height: 60,
      width: 45,
      child: TextField(
        autofocus: true,
        controller: controller,
        onChanged: (value) {
          if (value.length == 1 && last == false) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && first == false) {
            FocusScope.of(context).previousFocus();
          }
        },
        showCursor: false,
        readOnly: false,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counter: const Offstage(),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(width: 2, color: Colors.black12),
              borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  const BorderSide(width: 2, color: Colors.indigoAccent),
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfff7f6fb),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child:
                currentState == MobileVerificationState.SHOW_MOBILE_FORM_STATE
                    ? getMobileFormWidget(context)
                    : getOtpFormWidget(context),
          ),
        ),
      ),
    );
  }
}
