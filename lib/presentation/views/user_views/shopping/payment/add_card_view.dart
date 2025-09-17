import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:printfast_rebuild/presentation/widgets/widgets.dart';

class AddCardView extends StatefulWidget {
  const AddCardView({super.key});

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();
  final _cvcController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    _cvcController.dispose();
    super.dispose();
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
      title: "Agregar tarjeta",
      leadingIcon: Icons.add_card_rounded,
      leadingIconSize: 22,
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
                  child: _cardForm(context),
                ),
                const SizedBox(height: 20),
                _saveButton(context, colorScheme),
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
          "Agregar tarjeta",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Ingresa los datos de tu tarjeta",
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.inverseSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _cardForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        // Número de tarjeta
        _formField(
          context: context,
          label: "Número de tarjeta",
          hintText: "1234 5678 9012 3456",
          keyboardType: TextInputType.number,
          controller: _cardNumberController,
          prefixIcon: Icons.credit_card_rounded,
        ),
        const SizedBox(height: 16),

        // Titular de la tarjeta
        _formField(
          context: context,
          label: "Titular de la tarjeta",
          hintText: "JUAN PEREZ",
          keyboardType: TextInputType.text,
          controller: _cardHolderController,
          prefixIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 16),

        // Fecha de vencimiento y CVC - Mejor alineados
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vencimiento y CVC",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.inverseSurface.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fecha de vencimiento (MM/YY)
                Expanded(
                  child: _smallFormField(
                    context: context,
                    hintText: "MM/AA",
                    keyboardType: TextInputType.number,
                    controller: _expiryMonthController,
                    prefixIcon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 12),

                // CVC
                Expanded(
                  child: _smallFormField(
                    context: context,
                    hintText: "CVC",
                    keyboardType: TextInputType.number,
                    controller: _cvcController,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Checkbox para tarjeta predeterminada
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.4),
                  width: 1.2,
                ),
              ),
              child: Checkbox(
                value: true,
                onChanged: (value) {},
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                activeColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Establecer como predeterminada",
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.inverseSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _formField({
    required BuildContext context,
    required String label,
    required String hintText,
    required TextInputType keyboardType,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.inverseSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(
            color: colorScheme.inverseSurface,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(prefixIcon, color: Colors.blue, size: 18),
            hintText: hintText,
            hintStyle: TextStyle(
              color: colorScheme.inverseSurface.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.blue, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallFormField({
    required BuildContext context,
    required String hintText,
    required TextInputType keyboardType,
    required TextEditingController controller,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(
        color: colorScheme.inverseSurface,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: Icon(prefixIcon, color: Colors.blue, size: 18),
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.inverseSurface.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue, width: 1.2),
        ),
      ),
    );
  }

  Widget _saveButton(BuildContext context, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Guardar tarjeta y regresar
          context.pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.add_card_rounded, size: 18),
        label: const Text(
          "Guardar tarjeta",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}