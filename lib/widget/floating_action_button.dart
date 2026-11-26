import 'package:flutter/material.dart';
import 'package:pharma/model/colors.dart';
import 'package:pharma/provider/cart_provider.dart';
import 'package:pharma/screens/cart.dart';
import 'package:provider/provider.dart';

class NewFloatingActionButton extends StatelessWidget {
  const NewFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.blueLight : AppColors.blueDark;
    final iconColor = isDark ? AppColors.blueDark : AppColors.blueLight;

    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreenView()),
        );
      },
      backgroundColor: bgColor,
      shape: const CircleBorder(),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, color: iconColor),
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                final itemCount = cart.totalDistinctItems;
                if (itemCount == 0) return const SizedBox.shrink();

                return Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: bgColor, width: 0.0),
                    ),
                    child: Center(
                      child: Text(
                        itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
// class NewFloatingActionButton extends StatelessWidget {
//   const NewFloatingActionButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => CartScreenView()),
//         );
//       },
//       backgroundColor:
//           Theme.of(context).brightness == Brightness.dark
//               ? AppColors.blueLight
//               : AppColors.blueDark,
//       shape: const CircleBorder(), // Color de fondo del botón
//       child: Icon(
//         Icons.shopping_cart_outlined,
//         color:
//             Theme.of(context).brightness == Brightness.dark
//                 ? AppColors.blueDark
//                 : AppColors.blueLight,
//       ), // Icono de carrito
//     );
//   }
// }
