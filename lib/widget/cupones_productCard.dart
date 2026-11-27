import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma/model/card_model.dart';
import 'package:pharma/model/cupon_model.dart';
import 'package:pharma/provider/auth_provider.dart';
import 'package:pharma/provider/cart_provider.dart';
import 'package:pharma/screens/login.dart';
import 'package:pharma/screens/product_detail.dart';
import 'package:pharma/services/functions.dart';
import 'package:pharma/services/get_cupones.dart';
import 'package:pharma/widget/boton_agregar_wishList.dart';
import 'package:provider/provider.dart';

class CuponProductCard extends StatefulWidget {
  const CuponProductCard({super.key});

  @override
  State<CuponProductCard> createState() => _CuponProductCardState();
}

class _CuponProductCardState extends State<CuponProductCard> {
  @override
  Widget build(BuildContext context) {
    int selectedQuantity = 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      height: 240.0,
      child: FutureBuilder<List<ProductoConCupon>>(
        future: fetchProductosConCupon(),
        builder: (context, featured) {
          if (featured.hasData) {
            if (featured.data!.isEmpty) {
              return const Center(child: Text("0 Productos con Cupones"));
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: featured.data?.length,
              itemBuilder: (context, i) {
                final productoConCupon = featured.data![i];
                final product = productoConCupon.producto;
                final cupon = productoConCupon.cupon;

                final bool hasValidSalePrice =
                    product.onSale == 1 && product.priceSale.isNotEmpty && (double.tryParse(product.priceSale) ?? 0) > 0;

                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetail(data: product, cupon: cupon)));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 150, // Ancho fijo para cada tarjeta
                        height: 210,
                        margin: const EdgeInsets.fromLTRB(4, 4, 14, 0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 240, 250, 255),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromARGB((0.1 * 255).toInt(), 60, 60, 60),
                              spreadRadius: 3, // Extensión de la sombra
                              blurRadius: 4, // Desenfoque
                              offset: Offset(0, 0), // Posición (x, y)
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: <Widget>[
                                  AspectRatio(
                                    aspectRatio: 10 / 10, // Proporción para la imagen
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Container(
                                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          child: Image.network(
                                            product.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Center(child: Text('Error al cargar la imagen'));
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // if (cupon != null)
                                  Positioned(top: 8, left: 0, child: SizedBox(width: 40, child: Image.asset('assets/cupon.png'))),

                                  Positioned(top: 8.0, right: 8.0, child: BotonAgregarWishList(product: product)),

                                  // PRECIOS REBAJADO
                                  if (hasValidSalePrice)
                                    Positioned(
                                      bottom: 50,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                        child: Text(
                                          '₲${numberFormat(product.price)}',
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: Theme.of(context).hintColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),

                                  // Mostrar precio final (ya sea de oferta o regular)
                                  Positioned(
                                    bottom: 30,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                                      child: Text(
                                        '₲${numberFormat(hasValidSalePrice ? product.priceSale : product.price)}',
                                        style: TextStyle(
                                          color: hasValidSalePrice ? Colors.pink : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 32,
                                    right: 0,
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(Icons.shopping_cart_outlined),
                                      onPressed: () {
                                        final authProvider = Provider.of<AuthProvider>(context, listen: false);

                                        if (!authProvider.isAuthenticated) {
                                          // Si el usuario no está logeado, redirigirlo a LoginScreen
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                                          return; // Detiene la ejecución
                                        }

                                        final double effectivePrice =
                                            double.tryParse(hasValidSalePrice ? product.priceSale : product.price) ??
                                            double.tryParse(product.price) ??
                                            0.0;

                                        final cartItem = CartItem(
                                          id: product.id,
                                          name: product.name,
                                          price: effectivePrice,
                                          image: product.image,
                                          quantity: 1,
                                        );
                                        Provider.of<CartProvider>(context, listen: false).addToCart(cartItem, selectedQuantity);

                                        // Mostrar el SnackBar después de agregar el producto
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("${product.name} añadido al carrito"),
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 0,
                                    child: SizedBox(
                                      width: 138,
                                      child: Text(
                                        product.name.toUpperCase() + product.name.substring(1).toLowerCase(),
                                        style: GoogleFonts.quicksand(fontWeight: FontWeight.w600, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (featured.hasError) {
            return Center(child: Text(featured.error.toString()));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
