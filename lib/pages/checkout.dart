import 'package:hadaia/provider/cart.dart';
import 'package:hadaia/shared/appbar.dart';
import 'package:hadaia/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckOut extends StatelessWidget {
  const CheckOut({super.key});

  @override
  Widget build(BuildContext context) {
    final carttt = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appbarGreen,
        title: const Text("checkout screen"),
        actions: const [ProductsAndPrice()],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: 550,
              child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: carttt.selectedProducts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        title: Text(carttt.selectedProducts[index].name),
                        subtitle: Text(
                            "${carttt.selectedProducts[index].price} - ${carttt.selectedProducts[index].location}"),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(
                              carttt.selectedProducts[index].imgPath),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              carttt.delete(carttt.selectedProducts[index]);
                            },
                            icon: const Icon(Icons.remove)),
                      ),
                    );
                  }),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(BTNpink),
              padding: WidgetStateProperty.all(const EdgeInsets.all(12)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
            ),
            child: Text(
              "Pay \$${carttt.price}",
              style: const TextStyle(fontSize: 19),
            ),
          ),
        ],
      ),
    );
  }
}