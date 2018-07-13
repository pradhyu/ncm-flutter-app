
// Category State
//wc-api/v3/products/categories?fields=id,name,image,parent,count&filter[limit]=100
class Category {
  int id;
  String name;
  int parent;
  int count;
  String image;
  String description;

  Category.fromJson(Map json) {
    this.id = json['id'];
    this.name = json['name'];
    this.parent = json['parent'];
    this.count = json['count'];
    this.description = json['description'];
    var imgObj = json['image'];
    if (imgObj != null) {
      this.image = imgObj['src'].toString();
    } else {
      //default image
      this.image =
          "/wp-content/plugins/woocommerce/assets/images/placeholder.png";
    }
    // don't store prefix to optimize size of json
    this.image = "http://www.nepalconstructionmart.com" + this.image;
  }
  @override
  String toString() {
    return id.toString() + ':' + name + ':' + image;
  }
}



class ProductImage {
  int id;
  String src;
  int position;
  ProductImage.fromJson(Map json) {
    this.id = json['id'];
    this.src = json['src'];
    this.position = json['position'];
  }
}

class Product {
  int id;
  String title;
  int price;
  int regularPrice;
  String priceHtml;
  List<ProductImage> images = new List();
  List<String> categories =
      new List(); // for some reason category object is not used here

  Product.fromJson(Map json) {
    this.id = json['id'];
    this.title = json['title'];
    if (json['price'] != null && json['price'] != "") {
      this.price = int.parse(json['price']);
    }
    if (json['regular_price'] != null && json['regular_price'] != "") {
      this.regularPrice = int.parse(json['regular_price']);
    }
    this.priceHtml = json['price_html'];

    json['categories']?.forEach((categoryName) {
      this.categories.add(categoryName);
    });

    json['images']?.forEach((imageJson) {
      this.images.add(new ProductImage.fromJson(imageJson));
    });
  }
}

class ProductDetail {
  Product product;
  String description;
  String attributes; //??
  ProductDetail.fromJson(Map json) {
    this.description = json['description'];
  }
}