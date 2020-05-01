import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product-screen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _imageURLFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    price: 0,
    description: '',
    imageURL: '',
  );

  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageURL': '',
  };

  var _isInitLoaded = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageURLFocusNode.addListener(_updateImageURL);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInitLoaded) {
      final productID = ModalRoute.of(context).settings.arguments as String;
      if (productID != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findByID(productID);
        _initValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          'imageURL': '',
        };
        _imageURLController.text = _editedProduct.imageURL;
      }
    }
    _isInitLoaded = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageURLFocusNode.removeListener(_updateImageURL);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
    _imageURLFocusNode.dispose();
    super.dispose();
  }

  void _updateImageURL() {
    if (!_imageURLFocusNode.hasFocus) setState(() {});
  }

  String _validateTitle(String value) {
    if (value.isEmpty) return 'This field can\'t be empty.';
    return null;
  }

  String _validatePrice(String value) {
    if (value.isEmpty) return 'This field can\'t be empty.';
    if (double.tryParse(value) == null) return 'Please enter a valid number.';
    if (double.parse(value) <= 0) return 'Please enter a number bigger than 0.';

    return null;
  }

  String _validateDescription(String value) {
    if (value.isEmpty) return 'This field can\'t be empty.';
    if (value.length < 10)
      return 'Description should be at least 10 characters long.';

    return null;
  }

  String _validateURL(String value) {
    if (value.isEmpty) return 'This field can\'t be empty.';
    if (!value.startsWith('http') || !value.startsWith('https'))
      return 'Please enter a valid URL.';
    if (!value.endsWith('.jpg') &&
        !value.endsWith('.jpeg') &&
        !value.endsWith('.png')) return 'Please enter a valid URL.';

    return null;
  }

  Product _setOnSaved(String value, String inp) {
    switch (inp) {
      case 'title':
        {
          return Product(
            id: _editedProduct.id,
            title: value,
            price: _editedProduct.price,
            description: _editedProduct.description,
            imageURL: _editedProduct.imageURL,
            isFavorite: _editedProduct.isFavorite,
          );
        }
      case 'price':
        {
          return Product(
            id: _editedProduct.id,
            title: _editedProduct.title,
            price: double.parse(value),
            description: _editedProduct.description,
            imageURL: _editedProduct.imageURL,
            isFavorite: _editedProduct.isFavorite,
          );
        }
      case 'description':
        {
          return Product(
            id: _editedProduct.id,
            title: _editedProduct.title,
            price: _editedProduct.price,
            description: value,
            imageURL: _editedProduct.imageURL,
            isFavorite: _editedProduct.isFavorite,
          );
        }
      case 'imageURL':
        {
          return Product(
            id: _editedProduct.id,
            title: _editedProduct.title,
            price: _editedProduct.price,
            description: _editedProduct.description,
            imageURL: value,
            isFavorite: _editedProduct.isFavorite,
          );
        }
    }
    return null;
  }

  Future<void> _submitForm() async {
    final _isValid = _formKey.currentState.validate();
    if (!_isValid) return;
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .update(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false).add(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Error!'),
            content: Text('Oops! Something went wrong.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
    // Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () => _submitForm(),
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['title'],
                      decoration: InputDecoration(labelText: 'Title'),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      validator: (value) => _validateTitle(value),
                      onSaved: (value) {
                        _editedProduct = _setOnSaved(value, 'title');
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['price'],
                      decoration: InputDecoration(labelText: 'Price'),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      validator: (value) => _validatePrice(value),
                      onSaved: (value) {
                        _editedProduct = _setOnSaved(value, 'price');
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['description'],
                      decoration: InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      focusNode: _descriptionFocusNode,
                      validator: (value) => _validateDescription(value),
                      onSaved: (value) {
                        _editedProduct = _setOnSaved(value, 'description');
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(top: 10, right: 5),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageURLController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  child:
                                      Image.network(_imageURLController.text),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Image URL'),
                            controller: _imageURLController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageURLFocusNode,
                            validator: (value) => _validateURL(value),
                            onFieldSubmitted: (_) => _submitForm(),
                            onSaved: (value) {
                              _editedProduct = _setOnSaved(value, 'imageURL');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
