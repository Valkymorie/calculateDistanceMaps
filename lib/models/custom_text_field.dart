import 'package:flutter/material.dart';

class CustomTextField extends TextField {
  Widget buildCustomTextField({
    TextEditingController textEditingController,
    String label,
    String hint,
    String initialValue,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallBack,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) => locationCallBack(value),
        controller: textEditingController,
        decoration:  InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.grey.shade300,width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: Colors.lightBlue.shade300,width: 2),
          ),
          hintText: hint,
        ),
      ),
    );
  }
}
