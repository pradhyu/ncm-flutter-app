

import "./dataModel.dart";

abstract class Repository<T> {
  List<Category> get(int cacheIndex);
  void set(int cacheIndex, List<T> value);
}

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
