import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  TextEditingController _inputController = TextEditingController();
  String _result = "0";
  String _memory = "0";
  List<String> _history = [];

  void _onButtonPressed(String value) {
    setState(() {
      if (value == "C") {
        _inputController.clear();
        _result = "0";
      } else if (value == "=") {
        try {
          Parser parser = Parser();
          Expression exp = parser.parse(_inputController.text);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result = eval.toString();
          _history.add("${_inputController.text} = $_result");
        } catch (e) {
          _result = "Error";
        }
      } else if (value == "Solve Eq") {
        try {
          _result = _solveEquation(_inputController.text);
        } catch (e) {
          _result = "Error";
        }
      } else if (value == "M+") {
        _memory = _result;
      } else if (value == "M-") {
        _memory = "0";
      } else if (value == "MR") {
        _inputController.text += _memory;
      } else {
        _inputController.text += value;
      }
    });
  }

  String _solveEquation(String equation) {
    List<String> parts = equation.split('=');
    if (parts.length != 2) {
      return "Invalid Equation Format";
    }

    String left = parts[0];
    String right = parts[1];
    Parser parser = Parser();
    Expression leftExp = parser.parse(left);
    Expression rightExp = parser.parse(right);
    Expression exp = parser.parse("($left) - ($right)");

    double findRoot(Expression exp, double guess, ContextModel cm, [int maxIter = 1000, double tol = 1e-7]) {
      double x0 = guess;
      for (int i = 0; i < maxIter; i++) {
        cm.bindVariable(Variable('x'), Number(x0));
        double y = exp.evaluate(EvaluationType.REAL, cm);
        Expression dyExp = exp.derive('x');
        double dy = dyExp.evaluate(EvaluationType.REAL, cm);
        if (dy == 0) {
          throw Exception("Derivative is zero");
        }
        double x1 = x0 - y / dy;
        if ((x1 - x0).abs() < tol) {
          return x1;
        }
        x0 = x1;
      }
      throw Exception("No solution found");
    }

    try {
      ContextModel cm = ContextModel();
      double root = findRoot(exp, 0.0, cm);
      _history.add("${equation} => x = ${root.toStringAsFixed(7)}");
      return "x = ${root.toStringAsFixed(7)}";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Widget _buildButton(String value, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(value),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.all(20.0),
            backgroundColor: color,
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 24.0, color: Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.lightBlue[50],
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _inputController,
                    style: TextStyle(fontSize: 28.0),
                    decoration: InputDecoration(
                      hintText: "Enter equation or expression",
                      border: OutlineInputBorder(),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    _result,
                    style: TextStyle(fontSize: 36.0, color: Colors.blue),
                  ),
                ],
              ),
            ),
            Container(
              height: 120.0, // Limit the history container height
              color: Colors.blue[100],
              child: ListView(
                children: _history.map((entry) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(entry, style: TextStyle(fontSize: 18, color: Colors.black87)),
                )).toList(),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    _buildButton("7", Colors.blue[300]!),
                    _buildButton("8", Colors.blue[300]!),
                    _buildButton("9", Colors.blue[300]!),
                    _buildButton("/", Colors.blue[700]!),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("4", Colors.blue[300]!),
                    _buildButton("5", Colors.blue[300]!),
                    _buildButton("6", Colors.blue[300]!),
                    _buildButton("*", Colors.blue[700]!),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("1", Colors.blue[300]!),
                    _buildButton("2", Colors.blue[300]!),
                    _buildButton("3", Colors.blue[300]!),
                    _buildButton("-", Colors.blue[700]!),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("0", Colors.blue[300]!),
                    _buildButton(".", Colors.blue[300]!),
                    _buildButton("C", Colors.red),
                    _buildButton("+", Colors.blue[700]!),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("M+", Colors.blue[500]!),
                    _buildButton("M-", Colors.blue[500]!),
                    _buildButton("MR", Colors.blue[500]!),
                    _buildButton("=", Colors.green),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("Solve Eq", Colors.orange),
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
