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
    if (this.name == "" || this.name == null) {
      this.name = "Untitled";
    }
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
  String src;
  ProductImage.fromJson(Map json) {
    this.src = "http://www.nepalconstructionmart.com" + json['src'];
  }
}

// todo: fix duplicates in featured product and product. 
class FeaturedProduct extends Product {
  String description = "NA";
  FeaturedProduct.fromJson(Map json) {
     this.id = json['id'];
    this.name = json['name'];
    if (this.name == "" || this.name == null) {
      this.name = "Untitled";
    }
    if (json['price'] != null && json['price'] != "") {
      this.price = double.parse(json['price']);
    }
    if (json['regular_price'] != null && json['regular_price'] != "") {
      this.regularPrice = double.parse(json['regular_price']);
      // if non regular price division by zero so check price
      this.discount =
          (((this.regularPrice - this.price) / this.regularPrice) * 100);
    }

    if (this.priceHtml != null) {
      this.priceHtml = json['price_html'];
    }

    json['categories']?.forEach((categoryMap) {
      // categoryMap is json obj with id, name, slug
      this.categories.add(categoryMap['name']);
    });

    json['images']?.forEach((imageJson) {
      this.images.add(new ProductImage.fromJson(imageJson));
    });
    if (json[description]!=null){
    this.description = json[description];
    }
  }
}


class Product {
  int id;
  double price=0.0;
  double regularPrice=0.0;
  double discount=0.0;
  String name;
  String priceHtml;
  List<ProductImage> images = new List();
  List<String> categories =
      new List(); // for some reason category object is not used here

  Product(){
  }
  Product.fromJson(Map json) {
    this.id = json['id'];
    this.name = json['name'];
    if (this.name == "" || this.name == null) {
      this.name = "Untitled";
    }
    if (json['price'] != null && json['price'] != "") {
      this.price = double.parse(json['price']);
    }
    if (json['regular_price'] != null && json['regular_price'] != "") {
      this.regularPrice = double.parse(json['regular_price']);
      // if non regular price division by zero so check price
      this.discount =
          (((this.regularPrice - this.price) / this.regularPrice) * 100);
    }

    if (this.priceHtml != null) {
      this.priceHtml = json['price_html'];
    }

    json['categories']?.forEach((categoryMap) {
      // categoryMap is json obj with id, name, slug
      this.categories.add(categoryMap['name']);
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
