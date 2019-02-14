library woocommerce_api;

import 'dart:async';
import "dart:collection";
import 'dart:convert';
import "dart:math";
import "dart:core";
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart';
import './query_string.dart';
import 'package:http/http.dart' as http;

class WooCommerceAPI {
  var url;
  var consumerKey;
  var consumerSecret;

  WooCommerceAPI(url, consumerKey, consumerSecret){
    this.url = url;
    this.consumerKey = consumerKey;
    this.consumerSecret = consumerSecret;
  }


  _getOAuthURL(String request_method, String endpoint) {
    var consumerKey = this.consumerKey; //"ck_4e943ec0f3c76eba33fffac4b7fc0d2f1f3ca91a";
    var consumerSecret = this.consumerSecret; //"cs_fbb723138e354e30c3d4d4e0c0f95389bf610044";
    var token = "";
    var token_secret = "";
    //the url contains which version of wc api it wants to use
    String url = this.url + endpoint;


    var containsQueryParams = url.contains("?");

    var rand = new Random();
    var codeUnits = new List.generate(10, (index) {
      return rand.nextInt(26) + 97;
    });

    var nonce = new String.fromCharCodes(codeUnits);
    int timestamp = (new DateTime.now().millisecondsSinceEpoch / 1000).toInt();

    print(timestamp);
    print(nonce);

    var method = request_method;
    var path = url.split("?")[0];
    var parameters = "oauth_consumer_key=" +
        consumerKey +
        "&oauth_nonce=" +
        nonce +
        "&oauth_signature_method=HMAC-SHA1&oauth_timestamp=" +
        timestamp.toString() +
        "&oauth_token=" +
        token +
        "&oauth_version=1.0&";

    if (containsQueryParams == true) {
      parameters = parameters + url.split("?")[1];
    } else {
      parameters = parameters.substring(0, parameters.length - 1);
    }

    Map<dynamic, dynamic> params = QueryString.parse(parameters);
    Map<dynamic, dynamic> treeMap = new SplayTreeMap<dynamic, dynamic>();
    treeMap.addAll(params);

    String parameterString = "";

    for (var key in treeMap.keys) {
      parameterString = parameterString +
          Uri.encodeQueryComponent(key) +
          "=" +
          // replacing , with %2C is must to make oauth1 signature work if query params are fields=id,description
          treeMap[key].toString().toString().replaceAll("\,", "%2C") +
          "&";
    }

    parameterString = parameterString.substring(0, parameterString.length - 1);

    var baseString = method +
        "&" +
        Uri.encodeQueryComponent(
            containsQueryParams == true ? url.split("?")[0] : url) +
        "&" +
        Uri.encodeQueryComponent(parameterString);

    print("baseString=" +baseString);

    var signingKey = consumerSecret + "&" + token;
    print(signingKey);
    //print(UTF8.encode(signingKey));
    var hmacSha1 =
    new crypto.Hmac(crypto.sha1, utf8.encode(signingKey)); // HMAC-SHA1
    var signature = hmacSha1.convert(utf8.encode(baseString));

    print("signature=" + signature.toString());

    var finalSignature = base64Encode(signature.bytes);
    print("finalSignature=" + finalSignature);

    var requestUrl = "";

    if (containsQueryParams == true) {
      print(url.split("?")[0] +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature));
      requestUrl = url.split("?")[0] +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    } else {
      print(url +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature));
      requestUrl = url +
          "?" +
          parameterString +
          "&oauth_signature=" +
          Uri.encodeQueryComponent(finalSignature);
    }

    return requestUrl;
  }

  Future<Response> getAsync(String endPoint) async {

    var url = this._getOAuthURL("GET", endPoint);

    return http.get(url);

  }

  postAsync(String endPoint, Object data) async {

    var url = this._getOAuthURL("POST", endPoint);

    final response = await http.post(url, body: data);

    return json.decode(response.body);
  }
}