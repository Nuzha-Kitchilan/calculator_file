// Author - IM/2021/116 - F.N.Kitchilan

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = "0";
  String _expression = "";
  int _openParenthesesCount = 0;
  bool _isResultDisplayed = false;

  bool _isOperator(String character) {
    return ["+", "-", "×", "/", "%"].contains(character);
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _expression = "";
        _openParenthesesCount = 0;
        _isResultDisplayed = false;
      } else if (buttonText == "=") {
        try {
          if (_expression.isEmpty || _isOperator(_expression[_expression.length - 1])) {
            _output = "Error";
          } else {
            _expression = _expression.replaceAll("×", "*");
            Parser p = Parser();
            Expression exp = p.parse(_expression);
            ContextModel cm = ContextModel();

            // Evaluate the expression
            double eval = exp.evaluate(EvaluationType.REAL, cm);

            // Check for division by zero
            if (eval.isInfinite || eval.isNaN) {
              _output = "Error";
            } else {
              _output = eval.toString();
              _expression = _output;
              _isResultDisplayed = true;
            }
          }
        } catch (e) {
          _output = "Error";
          _isResultDisplayed = true;
        }
      } else if (buttonText == "DEL") {
        if (_expression.isNotEmpty) {
          if (_expression.endsWith('(')) {
            _openParenthesesCount--;
          } else if (_expression.endsWith(')')) {
            _openParenthesesCount++;
          }
          _expression = _expression.substring(0, _expression.length - 1);
          _output = _expression.isEmpty ? "0" : _expression;
        }
        _isResultDisplayed = false;
      } else if (buttonText == "()") {
        if (_openParenthesesCount > 0 && (_expression.isNotEmpty && _expression[_expression.length - 1] != '(')) {
          _expression += ")";
          _openParenthesesCount--;
        } else {
          _expression += "(";
          _openParenthesesCount++;
        }
        _output = _expression;
        _isResultDisplayed = false;
      } else if (buttonText == ".") {
        var lastNumber = _expression.split(RegExp(r'[+\-×/%]')).last;
        if (!lastNumber.contains(".")) {
          _expression += buttonText;
          _output = _expression;
        }
        _isResultDisplayed = false;
      } else if (buttonText == "√") {
        if (_expression.isNotEmpty) {
          try {
            Parser p = Parser();
            Expression exp = p.parse(_expression);
            ContextModel cm = ContextModel();
            double eval = exp.evaluate(EvaluationType.REAL, cm);
            if (eval < 0) {
              _output = "Error"; // No square root for negative numbers
            } else {
              _expression = sqrt(eval).toString();
              _output = _expression;
            }
            _isResultDisplayed = true;
          } catch (e) {
            _output = "Error";
          }
        }
      } else if (buttonText == "%") {
        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _expression = (eval / 100).toString();
          _output = _expression;
          _isResultDisplayed = true;
        } catch (e) {
          _output = "Error";
        }
      } else {
        if (_isOperator(buttonText) &&
            _expression.isNotEmpty &&
            _isOperator(_expression[_expression.length - 1])) {
          // Ignore duplicate operators
        } else {
          if (_isResultDisplayed && !_isOperator(buttonText)) {
            _expression = buttonText;
            _output = _expression;
            _isResultDisplayed = false;
          } else {
            if (_expression == "0" && buttonText != "." && !_isOperator(buttonText)) {
              _expression = buttonText;
            } else {
              _expression += buttonText;
            }
            _output = _expression;
            _isResultDisplayed = false;
          }
        }
      }
    });
  }

  Widget buildButton(String buttonText, {Color backgroundColor = Colors.black, Color borderColor = Colors.grey}) {
    return Container(
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 2.0),
        borderRadius: BorderRadius.circular(16),
      ),
      width: 80,
      height: 80,
      child: ElevatedButton(
        onPressed: () => buttonPressed(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: buttonText == "DEL"
            ? Icon(Icons.backspace, color: Colors.white, size: 24)
            : Text(
          buttonText,
          style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NuNu's Cal", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              child: Text(
                _output,
                style: const TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => buttonPressed("DEL"),
                  icon: const Icon(Icons.backspace, color: Colors.white, size: 30),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
              ],
            ),
            const SizedBox(
              height: 16.0,
              child: Divider(color: Colors.grey),
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("√", borderColor: Colors.deepPurple),
                    buildButton("C", borderColor: Colors.orange),
                    buildButton("()", borderColor: Colors.orange),
                    buildButton("/", borderColor: Colors.deepPurple),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("7"),
                    buildButton("8"),
                    buildButton("9"),
                    buildButton("×", borderColor: Colors.deepPurple),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("4"),
                    buildButton("5"),
                    buildButton("6"),
                    buildButton("-", borderColor: Colors.deepPurple),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("1"),
                    buildButton("2"),
                    buildButton("3"),
                    buildButton("+", borderColor: Colors.deepPurple),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildButton("%", borderColor: Colors.deepPurple),
                    buildButton("0"),
                    buildButton(".", borderColor: Colors.deepPurple),
                    buildButton("=", borderColor: Colors.green, backgroundColor: Colors.green),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
