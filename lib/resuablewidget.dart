import 'package:flutter/material.dart';

Container logoWidget(String imageName) {
  return Container(
    width: 250, // Specify the width of the container
    height: 250, // Specify the height of the container
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white, // Specify the border color
        width: 4.0, // Specify the border width
      ),
      image: DecorationImage(
        image: AssetImage(imageName),
        fit: BoxFit.cover,
      ),
    ),
  );
}


TextField reuseBar(String text, IconData icon, bool isPasswordtype,
    TextEditingController controller) {
  return TextField(
      controller: controller,
      obscureText: isPasswordtype,
      enableSuggestions: !isPasswordtype,
      autocorrect: !isPasswordtype,
      cursorColor: Colors.blueAccent,
      style: TextStyle(color: Colors.black.withOpacity(0.9)),
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Color.fromARGB(255, 150, 199, 222),
          
        ),
        labelText: text,
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.9)),
        filled: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(width: 0, style: BorderStyle.none,color: Color.fromARGB(255, 171, 226, 84))),
      ),
      keyboardType: isPasswordtype
          ? TextInputType.visiblePassword
          : TextInputType.emailAddress);
}

Container buttontoUse(BuildContext context, bool isLogin, Function onTap) {
  return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
      ),
      child: ElevatedButton(
          onPressed: () {
            onTap();
          },
          child: Text(
            isLogin ? "LOG IN" : " SING UP",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            } else {
              return Colors.white;
            }
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(100))),
          )));
}
