

import "./dataModel.dart";

abstract class Repository<T> {
  T get(int cacheIndex);
  void set(int cacheIndex, T value);
}
abstract class RepositoryForList<T> {
  List<T> get(int cacheIndex);
  void set(int cacheIndex, List<T> value);
}
// caches sub categories in the category
class CategoryCachingRepository extends RepositoryForList<Category> {
  final Map<int,List<Category>> cache;
  CategoryCachingRepository(this.cache);
  @override
    List<Category> get(int categoryIndex) {
      return cache[categoryIndex];
    }
    @override
      set(int categoryIndex, List<Category> value) {
        this.cache[categoryIndex]=value;
      }
}

// caches products in the category
class ProductCachingRepository extends RepositoryForList<Product> {
  final Map<int,List<Product>> cache;
  ProductCachingRepository(this.cache);
  @override
    List<Product> get(int categoryIndex) {
      return cache[categoryIndex];
    }
    @override
      set(int categoryIndex, List<Product> value) {
        this.cache[categoryIndex]=value;
      }
}
class FeaturedProductCachingRepository extends RepositoryForList<FeaturedProduct> {
  final Map<int,List<FeaturedProduct>> cache;
  FeaturedProductCachingRepository(this.cache);
  @override
    List<FeaturedProduct> get(int categoryIndex) {
      return cache[categoryIndex];
    }
    @override
      set(int categoryIndex, List<FeaturedProduct> value) {
        this.cache[categoryIndex]=value;
      }
}


class ProductDetailCachingRepository extends Repository<ProductDetail> {
  final Map<int,ProductDetail> cache;
  ProductDetailCachingRepository(this.cache);
  @override
    ProductDetail get(int index) {
      return cache[index];
    }
    @override
      set(int index, ProductDetail value) {
        this.cache[index]=value;
      }
}
