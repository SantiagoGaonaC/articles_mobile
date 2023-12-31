import 'package:articles_flutter/features/products/domain/datasource/product_datasource.dart';
import 'package:articles_flutter/features/products/domain/entities/products.dart';
import 'package:articles_flutter/features/products/domain/repositories/product_repository.dart';

class ProductsRepositoryImpl extends ProductsRepository {
  final ProductsDataSource dataSources;

  ProductsRepositoryImpl(this.dataSources);

  @override
  Future<List<Products>> getProducts() {
    return dataSources.getProducts();
  }

  @override
  Future<List<Products>> getFavorites() {
    return dataSources.getFavorites();
  }

  @override
  Future<Products> addFavorite(
    Products product,
  ) {
    return dataSources.addFavorite(product);
  }

  @override
  Future<Products> removeFavorite(
    Products product,
  ) {
    return dataSources.removeFavorite(product);
  }
}
