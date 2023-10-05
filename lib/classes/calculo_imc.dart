class CalculoIMC {
  double _imc = 0.0;

  double get imc => _imc;

  set imc(double value) {
    _imc = value;
  }

  double calcularIMC(var peso, var altura) {
    var imc = peso / (altura * altura);
    double imcTruncado = double.parse(imc.toStringAsFixed(2));
    return imcTruncado;
  }

  String getClassificacao(_imc) {
    if (_imc < 16) {
      return 'Magreza Grave';
    } else if (_imc < 17) {
      return 'Magreza Moderada';
    } else if (_imc < 18.5) {
      return 'Magreza Leve';
    } else if (_imc < 25) {
      return 'Saudável';
    } else if (_imc < 30) {
      return 'Sobrepeso';
    } else if (_imc < 35) {
      return 'Obesidade Grau I';
    } else if (_imc < 40) {
      return 'Obesidade Grau II (severa)';
    } else {
      return 'Obesidade Grau III (mórbida)';
    }
  }
}
