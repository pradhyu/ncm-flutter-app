
import "./woocommerce_api.dart";
import "./dataModel.dart";
import 'dart:async';
import 'dart:convert';
import "./cacheManager.dart";
import 'dart:convert';
import 'package:http/http.dart' as http;


// woo parameters
// for oauth1 authentication
WooCommerceAPI wc_api = new WooCommerceAPI(
    "http://www.nepalconstructionmart.com",
    "ck_b3b26bf14e1193829ec21ca2c8ae355be3855fc6",
    "cs_69ddf520c834a509c41557c4ab145b8c24e0754e");

final Map<int, List<Category>> categoryCacheHolder = {};
CategoryCachingRepository categoryCacheRepo =
    new CategoryCachingRepository(categoryCacheHolder);

final Map<int, List<Product>> productCacheHolder = {};
ProductCachingRepository productCacheRepo =
    new ProductCachingRepository(productCacheHolder);

final Map<int, List<FeaturedProduct>> featuredProductCacheHolder = {};
FeaturedProductCachingRepository featuredProductCacheRepo =
    new FeaturedProductCachingRepository(featuredProductCacheHolder);

final Map<int, ProductDetail> productDetailCacheHolder = {};
ProductDetailCachingRepository productDetailCacheRepo =
    new ProductDetailCachingRepository(productDetailCacheHolder);



// cache calls
Future<List<FeaturedProduct>> forceCacheFeaturedProducts(
    int pageId, int itemsLimit) async {
  var _productsList = await wc_api
      .getAsync("/wp-json/wc/v2/products/?per_page=" +
          itemsLimit.toString() +
          "&page=" +
          pageId.toString() +
          "&featured=true&_fields=name,id,short_description,categories,price,regular_price,sale_price,on_sale,featured,images")
      .then((val) {
    List<FeaturedProduct> _featuredProducts = new List();
    List productMapList = JSON.decode(val.body);
    productMapList?.forEach((f) {
      var prod = new FeaturedProduct.fromJson(f);
      _featuredProducts.add(prod);
    });
    featuredProductCacheRepo.set(pageId, _featuredProducts);
    return _featuredProducts;
  });
  return _productsList;
}

Future<List<Product>> forceCacheProducts(int pageId, int itemsLimit) async {
  var _productsList = await wc_api
      .getAsync("/wp-json/wc/v2/products/?per_page=" +
          itemsLimit.toString() +
          "&page=" +
          pageId.toString() +
          "&_fields=name,id,categories,price,regular_price,sale_price,images")
      .then((val) {
    List<Product> _products = new List();
    List productMapList = JSON.decode(val.body);
    productMapList?.forEach((f) {
      var prod = new Product.fromJson(f);
      _products.add(prod);
    });
    productCacheRepo.set(pageId, _products);
    return _products;
  });
  return _productsList;
}

Future<List<Category>> forceCacheCategories(int parentId) async {
  var restUrl = "/wp-json/wc/v2/products/categories?parent=" +
      parentId.toString() +
      "&_fields=id,name,image,parent,count,description&per_page=100";
  List<Category> _categoryList = await wc_api
      // only show parent=0 that's major category
      // then drill down to sub-categories
      .getAsync(restUrl)
      .then((val) {
    //v2 rest api woo /wordpress returns list of maps with category
    List categoriesMapList = JSON.decode(val.body);
    List<Category> _categories = new List();
    categoriesMapList.forEach((f) {
      _categories.add(new Category.fromJson(f));
    });
    categoryCacheRepo.set(parentId, _categories);
    return _categories;
  });
  return _categoryList;
}


// cache calls
Future<ProductDetail> forceCacheProductDetail(
    int productId) async {
  var _productDetail = await wc_api
      .getAsync("/wp-json/wc/v2/products/" +
          productId.toString() +
          "?_fields=name,id,tags,related_ids,permalink,description,categories,price,regular_price,sale_price,on_sale,featured,images")
      .then((val) {
    var productJsonMap= JSON.decode(val.body);
      ProductDetail productDetail= new ProductDetail.fromJson(productJsonMap);
    productDetailCacheRepo.set(productId, productDetail);
    return  productDetail;
  });
  return _productDetail;
}