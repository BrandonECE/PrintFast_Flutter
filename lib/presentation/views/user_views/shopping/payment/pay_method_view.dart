import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/config/routes/routes.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class MyPayMethodView extends StatefulWidget {
  const MyPayMethodView({super.key});

  @override
  State<MyPayMethodView> createState() => _MyPayMethodViewState();
}

class _MyPayMethodViewState extends State<MyPayMethodView> {
  String? _selectedMethod;
  final List<Map<String, dynamic>> _savedCards = [
    {
      'id': 'card_1',
      'lastFour': '1234',
      'type': 'Visa',
      'icon': Icons.credit_card_rounded,
      'expMonth': '12',
      'expYear': '25',
      'cvc': '123',
      'isDefault': true, // Tarjeta por defecto
    },
    {
      'id': 'card_2', 
      'lastFour': '5678',
      'type': 'Mastercard',
      'icon': Icons.credit_card_rounded,
      'expMonth': '06',
      'expYear': '26',
      'cvc': '456',
      'isDefault': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Seleccionar automáticamente la tarjeta por defecto si existe
    final defaultCard = _savedCards.firstWhere(
      (card) => card['isDefault'] == true,
      orElse: () => _savedCards.isNotEmpty ? _savedCards.first : {},
    );
    if (defaultCard.isNotEmpty) {
      _selectedMethod = defaultCard['id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: _myAppBar(context),
      body: _myBody(width, context),
    );
  }

  MyAppBarWidget _myAppBar(BuildContext context) {
    return MyAppBarWidget(
      title: "Método de pago",
      leadingIcon: Icons.credit_card_rounded,
      leadingIconSize: 24,
      actionIcon: Icons.close_rounded,
      actionIconSize: 22,
      onAction: () => context.canPop() ? context.pop() : null,
    );
  }

  Widget _myBody(double width, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: width * 0.025),
        child: Container(
          width: width * 0.95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerSection(colorScheme),
                const SizedBox(height: 20),
                Expanded(
                  child: _paymentMethodsList(context),
                ),
                const SizedBox(height: 16),
                _addCardButton(context, colorScheme),
                const SizedBox(height: 20),
                _confirmButton(context, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Método de pago",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Selecciona cómo deseas pagar",
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _paymentMethodsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      shrinkWrap: true,
      children: [
        // Sección de tarjetas guardadas
        if (_savedCards.isNotEmpty) ...[
          Text(
            "Tarjetas guardadas",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.inverseSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 12),
          ..._savedCards.map((card) => _paymentOption(
            context: context,
            id: card['id'],
            icon: card['icon'],
            title: "**** **** **** ${card['lastFour']}",
            subtitle: "${card['type']} • Vence ${card['expMonth']}/${card['expYear']}",
            color: Colors.blue,
            isSelected: _selectedMethod == card['id'],
            isDefault: card['isDefault'],
            onSelected: (selected) {
              setState(() {
                _selectedMethod = selected ? card['id'] : null;
              });
            },
          )),
          const SizedBox(height: 16),
        ] else ...[
          // Estado cuando no hay tarjetas
          _noCardsPlaceholder(context),
          const SizedBox(height: 16),
        ],

        // Opción de efectivo
        _paymentOption(
          context: context,
          id: 'cash',
          icon: Icons.money_rounded,
          title: "Efectivo",
          subtitle: "Paga al recibir tu pedido",
          color: Colors.orange,
          isSelected: _selectedMethod == 'cash',
          isDefault: false,
          onSelected: (selected) {
            setState(() {
              _selectedMethod = selected ? 'cash' : null;
            });
          },
        ),
      ],
    );
  }

  Widget _paymentOption({
    required BuildContext context,
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required bool isDefault,
    required Function(bool) onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSelected(!isSelected),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Checkbox circular
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? color : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded, 
                          color: Colors.white, 
                          size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                
                // Icono del método
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                
                // Información
                Expanded(
                  child: Column(
                  
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.inverseSurface,
                            ),
                          ),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                              ),
                              child: Text(
                                "Predet.",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.inverseSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _noCardsPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(Icons.credit_card_off_rounded, 
              size: 32, 
              color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            "No tienes tarjetas guardadas",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.inverseSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Agrega una tarjeta para pagar con ella",
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.inverseSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

Widget _addCardButton(BuildContext context, ColorScheme colorScheme) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => context.push(Routes.addCard),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: Colors.blue, size: 16),
            const SizedBox(width: 8),
            Text(
              "Agregar tarjeta",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
  
  Widget _confirmButton(BuildContext context, ColorScheme colorScheme) {
    final isMethodSelected = _selectedMethod != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isMethodSelected
            ? () {
                // // Confirmar pago y proceder
                // print("Método seleccionado: $_selectedMethod");
                // context.pop();
                context.go(Routes.home);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isMethodSelected ? Colors.green : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.payment_rounded, size: 20),
        label: const Text(
          "Confirmar pago",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}