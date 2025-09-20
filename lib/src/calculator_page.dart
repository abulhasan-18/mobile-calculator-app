import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'widgets/calc_button.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.onSystemTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme; // tap: light<->dark
  final VoidCallback onSystemTheme; // long-press: back to system

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _expressionCtrl = TextEditingController();
  String _result = '0';
  bool _showScientific = true;

  // Safe append
  void _append(String v) {
    setState(() {
      if (_expressionCtrl.text == '0' && v != '.') {
        _expressionCtrl.text = v;
      } else {
        _expressionCtrl.text += v;
      }
    });
  }

  void _clear() {
    setState(() {
      _expressionCtrl.text = '';
      _result = '0';
    });
  }

  void _backspace() {
    setState(() {
      if (_expressionCtrl.text.isNotEmpty) {
        _expressionCtrl.text =
            _expressionCtrl.text.substring(0, _expressionCtrl.text.length - 1);
      }
      if (_expressionCtrl.text.isEmpty) _result = '0';
    });
  }

  void _evaluate() {
    final raw = _expressionCtrl.text.trim();
    if (raw.isEmpty) return;

    try {
      var expr = raw
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('^', '^')
          .replaceAll('π', '${math.pi}')
          .replaceAll('e', '${math.e}');

      // percentages: 50% -> (50/100)
      expr = expr.replaceAllMapped(
          RegExp(r'(\d+(\.\d+)?)%'), (m) => '(${m.group(1)}/100)');

      final p = Parser();
      final cm = ContextModel();
      final parsed = p.parse(expr);
      final val = parsed.evaluate(EvaluationType.REAL, cm);

      setState(() => _result = _beautify(val));
    } catch (_) {
      setState(() => _result = 'Error');
    }
  }

  String _beautify(num v) {
    final s = v.toString();
    if (s.contains('.') && s.endsWith('0')) return num.parse(s).toString();
    if (s.contains('.')) {
      final parts = s.split('.');
      if (parts[1].length > 10) {
        return v.toStringAsFixed(10).replaceFirst(RegExp(r'\.?0+$'), '');
      }
    }
    return s;
  }

  @override
  void dispose() {
    _expressionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    IconData themeIcon() {
      // show icon based on *effective* theme
      if (widget.themeMode == ThemeMode.system) {
        return isDark ? Icons.brightness_2 : Icons.brightness_5; // moon/sun-ish
      }
      return (widget.themeMode == ThemeMode.dark)
          ? Icons.dark_mode
          : Icons.light_mode;
    }

    String themeTooltip() {
      final m = widget.themeMode;
      return m == ThemeMode.system
          ? 'Theme: System (tap to toggle, long-press to keep System)'
          : 'Theme: ${m == ThemeMode.dark ? "Dark" : "Light"} (tap to toggle, long-press System)';
    }

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('CALC PRO'),
        centerTitle: true,
        scrolledUnderElevation: 0,
        actions: [
          // THEME TOGGLE (near the scientific icon)
          GestureDetector(
            onLongPress: widget.onSystemTheme, // long-press -> system
            child: IconButton(
              tooltip: themeTooltip(),
              icon: Icon(themeIcon()),
              onPressed: widget.onToggleTheme, // tap -> light<->dark
            ),
          ),
          // Scientific toggle
          IconButton(
            tooltip: _showScientific ? 'Hide scientific' : 'Show scientific',
            icon:
                Icon(_showScientific ? Icons.science : Icons.science_outlined),
            onPressed: () => setState(() => _showScientific = !_showScientific),
          ),
        ],
      ),
      body: DecoratedBox(
        // subtle backdrop gradient that adapts to theme
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [cs.surface, cs.surfaceContainerHigh]
                : [cs.surface, cs.surfaceContainerHighest],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Display card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: DecoratedBox(
                  decoration: ShapeDecoration(
                    color: cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: cs.outlineVariant),
                    ),
                    shadows: [
                      BoxShadow(
                        color: cs.shadow.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _expressionCtrl,
                          readOnly: true, // we use custom keys
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 30, height: 1.2),
                          decoration: const InputDecoration(
                            hintText: 'Enter expression',
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          maxLines: 2,
                          keyboardType: TextInputType.none,
                        ),
                        const SizedBox(height: 10),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _result,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                              height: 1.1,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Scientific pad
              if (_showScientific)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: _ScientificPad(
                    onTap: _append,
                    onFn: _applyFunc,
                    onPow: _pow,
                    onSqrt: _sqrt,
                  ),
                ),

              // Main pad
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: cs.outlineVariant),
                      ),
                    ),
                    child: _MainPad(
                      onTap: _append,
                      onClear: _clear,
                      onBackspace: _backspace,
                      onEquals: _evaluate,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomHints(isDark: isDark),
    );
  }

  // scientific helpers
  void _applyFunc(String fnName) => _append('$fnName(');
  void _pow() => _append('^');
  void _sqrt() => _append('sqrt(');
}

class _ScientificPad extends StatelessWidget {
  final void Function(String) onTap;
  final void Function(String fnName) onFn;
  final VoidCallback onPow;
  final VoidCallback onSqrt;

  const _ScientificPad({
    required this.onTap,
    required this.onFn,
    required this.onPow,
    required this.onSqrt,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <List<Widget>>[
      [
        CalcButton(label: '(', onTap: () => onTap('(')),
        CalcButton(label: ')', onTap: () => onTap(')')),
        CalcButton(label: 'π', onTap: () => onTap('π')),
        CalcButton(label: 'e', onTap: () => onTap('e')),
      ],
      [
        CalcButton(label: 'sin', onTap: () => onFn('sin')),
        CalcButton(label: 'cos', onTap: () => onFn('cos')),
        CalcButton(label: 'tan', onTap: () => onFn('tan')),
        CalcButton(label: '√', onTap: onSqrt),
      ],
      [
        CalcButton(label: 'ln', onTap: () => onFn('ln')),
        CalcButton(label: 'log', onTap: () => onFn('log')),
        CalcButton(label: '^', onTap: onPow),
        CalcButton(label: '%', onTap: () => onTap('%')),
      ],
    ];

    return Column(
      children: rows
          .map(
            (r) => Row(
              children: r
                  .map((w) => Expanded(
                        child:
                            Padding(padding: const EdgeInsets.all(4), child: w),
                      ))
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}

class _MainPad extends StatelessWidget {
  final void Function(String) onTap;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onEquals;

  const _MainPad({
    required this.onTap,
    required this.onClear,
    required this.onBackspace,
    required this.onEquals,
  });

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['AC', '(', ')', '⌫'],
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['0', '.', '=', '+'],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: keys.map((row) {
          return Expanded(
            child: Row(
              children: row.map((label) {
                final isOp = '÷×-+=()'.contains(label);
                final isEquals = label == '=';
                final isDanger = label == 'AC';

                void tap() {
                  switch (label) {
                    case 'AC':
                      onClear();
                      break;
                    case '⌫':
                      onBackspace();
                      break;
                    case '=':
                      onEquals();
                      break;
                    default:
                      onTap(_mapInput(label));
                  }
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: CalcButton(
                      label: label,
                      onTap: tap,
                      tone: isEquals
                          ? ButtonTone.primary
                          : isDanger
                              ? ButtonTone.tonal
                              : (isOp
                                  ? ButtonTone.secondary
                                  : ButtonTone.surface),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _mapInput(String l) {
    switch (l) {
      case '÷':
      case '×':
      case '+':
      case '-':
      case '.':
      case '(':
      case ')':
        return l;
      case '=':
        return '';
      default:
        return l;
    }
  }
}

class _BottomHints extends StatefulWidget {
  final bool isDark;
  const _BottomHints({required this.isDark});

  @override
  State<_BottomHints> createState() => _BottomHintsState();
}

class _BottomHintsState extends State<_BottomHints> {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Created by • Mohammed Abulhasan', style: t),
          Text('sin/cos/tan, ln/log, π, e, ^, √, %', style: t),
        ],
      ),
    );
  }
}
