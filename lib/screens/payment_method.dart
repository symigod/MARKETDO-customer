import 'package:flutter/material.dart';

class PaymentMethods extends StatefulWidget {
  const PaymentMethods({Key? key}) : super(key: key);

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  
  bool _isCashOnDeliverySelected = false;
  bool _isGCashSelected = false;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Payment Method',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Cash on Delivery'),
                trailing: Checkbox(
                  value: _isCashOnDeliverySelected,
                  onChanged: (value) {
                    setState(() {
                      _isCashOnDeliverySelected = value ?? false;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _isCashOnDeliverySelected = !_isCashOnDeliverySelected;
                    _isGCashSelected = false;
                  });
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('GCash'),
                trailing: Checkbox(
                  value: _isGCashSelected,
                  onChanged: (value) {
                    setState(() {
                      _isGCashSelected = value ?? false;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _isGCashSelected = !_isGCashSelected;
                    _isCashOnDeliverySelected = false;
                  });
                },
              ),
            ),
            if (_isGCashSelected)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Pay your balance in 5 hours, to process your orders.\nSend Money to 09454336651 (Arnulfo Godinez)',
                  style: TextStyle(
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red),
          ),
          child: const Text(
            'Place my Order',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: ()  { 
              
            },

        ),
      ),
    );
  }

  
}
