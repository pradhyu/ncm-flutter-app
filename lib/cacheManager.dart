

import "./dataModel.dart";

abstract class Repository<T> {
  List<T> get(int cacheIndex);
  void set(int cacheIndex, List<T> value);
}

// caches sub categories in the category
class CategoryCachingRepository extends Repository<Category> {
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
class ProductCachingRepository extends Repository<Product> {
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