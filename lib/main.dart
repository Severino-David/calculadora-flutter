import 'package:flutter/material.dart';

void main() {
  runApp(const CalculadoraApp());
}

class CalculadoraApp extends StatelessWidget {
  const CalculadoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const CalculadoraPage(),
    );
  }
}

class CalculadoraPage extends StatefulWidget {
  const CalculadoraPage({super.key});

  @override
  State<CalculadoraPage> createState() => _CalculadoraPageState();
}

class _CalculadoraPageState extends State<CalculadoraPage> {
  bool modoEscuro = true;

  String expressao = '';
  String resultado = '0';

  double? primeiroNumero;
  String? operacao;
  bool novoNumero = true;

  // ============================================================
  // CÁLCULOS
  // ============================================================

  void pressionarNumero(String numero) {
    setState(() {
      if (novoNumero || resultado == '0') {
        resultado = numero;
        novoNumero = false;
      } else {
        resultado += numero;
      }
    });
  }

  void pressionarPonto() {
    setState(() {
      if (novoNumero) {
        resultado = '0.';
        novoNumero = false;
      } else if (!resultado.contains('.')) {
        resultado += '.';
      }
    });
  }

  void pressionarOperacao(String op) {
    setState(() {
      primeiroNumero = double.tryParse(resultado);
      operacao = op;
      expressao = '$resultado $op';
      novoNumero = true;
    });
  }

  void calcular() {
    if (primeiroNumero == null || operacao == null) {
      return;
    }

    final segundoNumero = double.tryParse(resultado);

    if (segundoNumero == null) {
      return;
    }

    double valor = 0;

    switch (operacao) {
      case '+':
        valor = primeiroNumero! + segundoNumero;
        break;

      case '-':
        valor = primeiroNumero! - segundoNumero;
        break;

      case '×':
        valor = primeiroNumero! * segundoNumero;
        break;

      case '÷':
        if (segundoNumero == 0) {
          setState(() {
            resultado = 'Erro';
            expressao = '';
            primeiroNumero = null;
            operacao = null;
            novoNumero = true;
          });
          return;
        }

        valor = primeiroNumero! / segundoNumero;
        break;
    }

    setState(() {
      expressao =
          '${formatar(primeiroNumero!)} $operacao ${formatar(segundoNumero)}';

      resultado = formatar(valor);

      primeiroNumero = null;
      operacao = null;
      novoNumero = true;
    });
  }

  void limpar() {
    setState(() {
      expressao = '';
      resultado = '0';
      primeiroNumero = null;
      operacao = null;
      novoNumero = true;
    });
  }

  void apagar() {
    setState(() {
      if (resultado.length > 1 && resultado != 'Erro') {
        resultado = resultado.substring(0, resultado.length - 1);
      } else {
        resultado = '0';
        novoNumero = true;
      }
    });
  }

  void inverterSinal() {
    setState(() {
      if (resultado == '0' || resultado == 'Erro') {
        return;
      }

      if (resultado.startsWith('-')) {
        resultado = resultado.substring(1);
      } else {
        resultado = '-$resultado';
      }
    });
  }

  void porcentagem() {
    setState(() {
      final numero = double.tryParse(resultado);

      if (numero != null) {
        resultado = formatar(numero / 100);
      }
    });
  }

  String formatar(double numero) {
    if (numero == numero.roundToDouble()) {
      return numero.toInt().toString();
    }

    return numero
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '');
  }

  // ============================================================
  // BOTÃO
  // ============================================================

  Widget botao(
    String texto, {
    bool operacao = false,
    bool igual = false,
    bool acao = false,
  }) {
    final bool dark = modoEscuro;

    Color fundo;

    if (operacao || igual) {
      fundo = const Color(0xFF4355FF);
    } else if (dark) {
      fundo = const Color(0xFF303035);
    } else {
      fundo = Colors.white;
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: fundo,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (texto == 'C') {
                limpar();
              } else if (texto == '⌫') {
                apagar();
              } else if (texto == '+/−') {
                inverterSinal();
              } else if (texto == '%') {
                porcentagem();
              } else if (texto == '=') {
                calcular();
              } else if (['+', '-', '×', '÷'].contains(texto)) {
                pressionarOperacao(texto);
              } else if (texto == '.') {
                pressionarPonto();
              } else {
                pressionarNumero(texto);
              }
            },
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  texto,
                  style: TextStyle(
                    color: (operacao || igual)
                        ? Colors.white
                        : (dark ? Colors.white : Colors.black),
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LINHA DOS BOTÕES
  // ============================================================

  Widget linha(List<Widget> botoes) {
    return Expanded(
      child: Row(
        children: botoes,
      ),
    );
  }

  // ============================================================
  // BOTÃO DARK/LIGHT
  // ============================================================

  Widget botaoTema() {
    final bool dark = modoEscuro;

    return GestureDetector(
      onTap: () {
        setState(() {
          modoEscuro = !modoEscuro;
        });
      },
      child: Container(
        width: 58,
        height: 30,
        decoration: BoxDecoration(
          color: dark
              ? const Color(0xFF303035)
              : const Color(0xFFD6DADC),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(3),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment:
              dark ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF56565D)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              dark ? Icons.dark_mode : Icons.light_mode,
              size: 15,
              color: const Color(0xFF4355FF),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bool dark = modoEscuro;

    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF151519) : const Color(0xFFF0F5F5),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {

            // ------------------------------------------------
            // DIMENSÕES DA TELA
            // ------------------------------------------------

            final double largura = constraints.maxWidth;
            final double altura = constraints.maxHeight;

            final bool telaDeitada = largura > altura;

            // ------------------------------------------------
            // TAMANHO MÁXIMO DA CALCULADORA
            // ------------------------------------------------

            double larguraCalculadora;

            if (largura < 500) {
              // CELULAR
              larguraCalculadora = largura;
            } else if (largura < 900) {
              // TABLET
              larguraCalculadora = 480;
            } else {
              // COMPUTADOR
              larguraCalculadora = 430;
            }

            // Nunca ultrapassa a tela
            larguraCalculadora =
                larguraCalculadora.clamp(0, largura);

            // ------------------------------------------------
            // CONTAINER PRINCIPAL
            // ------------------------------------------------

            return Center(
              child: SizedBox(
                width: larguraCalculadora,

                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: largura < 500 ? 16 : 20,
                    vertical: telaDeitada ? 4 : 10,
                  ),

                  child: Column(
                    children: [

                      // ======================================
                      // TEMA
                      // ======================================

                      SizedBox(
                        height: telaDeitada ? 25 : 35,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: botaoTema(),
                        ),
                      ),

                      // ======================================
                      // VISOR
                      // ======================================

                      Expanded(
                        flex: telaDeitada ? 2 : 3,

                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),

                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.end,

                            crossAxisAlignment:
                                CrossAxisAlignment.end,

                            children: [

                              // Expressão
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,

                                  alignment:
                                      Alignment.centerRight,

                                  child: Text(
                                    expressao,

                                    style: TextStyle(
                                      color: dark
                                          ? Colors.white38
                                          : Colors.black38,
                                      fontSize:
                                          telaDeitada ? 18 : 22,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(
                                height:
                                    telaDeitada ? 0 : 4,
                              ),

                              // Resultado
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,

                                  alignment:
                                      Alignment.centerRight,

                                  child: Text(
                                    resultado,

                                    style: TextStyle(
                                      color: dark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize:
                                          telaDeitada ? 48 : 64,
                                      fontWeight:
                                          FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: telaDeitada ? 4 : 10,
                      ),

                      // ======================================
                      // BOTÕES
                      // ======================================

                      Expanded(
                        flex: telaDeitada ? 7 : 7,

                        child: Column(
                          children: [

                            linha([
                              botao(
                                'C',
                                acao: true,
                              ),
                              botao(
                                '+/−',
                                acao: true,
                              ),
                              botao(
                                '%',
                                acao: true,
                              ),
                              botao(
                                '÷',
                                operacao: true,
                              ),
                            ]),

                            linha([
                              botao('7'),
                              botao('8'),
                              botao('9'),
                              botao(
                                '×',
                                operacao: true,
                              ),
                            ]),

                            linha([
                              botao('4'),
                              botao('5'),
                              botao('6'),
                              botao(
                                '-',
                                operacao: true,
                              ),
                            ]),

                            linha([
                              botao('1'),
                              botao('2'),
                              botao('3'),
                              botao(
                                '+',
                                operacao: true,
                              ),
                            ]),

                            linha([
                              botao('.'),
                              botao('0'),
                              botao(
                                '⌫',
                                acao: true,
                              ),
                              botao(
                                '=',
                                igual: true,
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}