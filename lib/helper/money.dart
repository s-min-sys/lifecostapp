String priceToUIYuanStringWithYuan(int price) {
  return '${priceToUIYuanString(price)} 元';
}

String priceToUIYuanString(int price) {
  return (price / 100).toString();
}

int uiYuanStringToPrice(String s) {
  if (s == '') {
    return 0;
  }
  return (double.parse(s) * 100).toInt();
}
