// 线路编号比较，数字优先且从小到大，字母按A-Z顺序
int compareLineNumbers(String a, String b) {
  // 提取数字和字母部分
  RegExp digitRegex = RegExp(r'^\d+');
  RegExp letterRegex = RegExp(r'^[A-Z]+');

  bool aIsDigit = digitRegex.hasMatch(a);
  bool bIsDigit = digitRegex.hasMatch(b);

  // 数字线路排在字母线路前面
  if (aIsDigit && !bIsDigit) return -1;
  if (!aIsDigit && bIsDigit) return 1;

  if (aIsDigit && bIsDigit) {
    // 都是数字,按数值大小排序
    int aNum = int.parse(digitRegex.firstMatch(a)!.group(0)!);
    int bNum = int.parse(digitRegex.firstMatch(b)!.group(0)!);
    return aNum.compareTo(bNum);
  } else {
    // 都是字母开头,先比较字母部分
    String aLetter =
        letterRegex.hasMatch(a) ? letterRegex.firstMatch(a)!.group(0)! : a;
    String bLetter =
        letterRegex.hasMatch(b) ? letterRegex.firstMatch(b)!.group(0)! : b;

    int letterCompare = aLetter.compareTo(bLetter);
    if (letterCompare != 0) return letterCompare;

    // 字母相同,比较后面的数字
    String aRest = a.substring(aLetter.length);
    String bRest = b.substring(bLetter.length);

    if (aRest.isEmpty && bRest.isEmpty) return 0;
    if (aRest.isEmpty) return -1;
    if (bRest.isEmpty) return 1;

    if (digitRegex.hasMatch(aRest) && digitRegex.hasMatch(bRest)) {
      int aNum = int.parse(aRest);
      int bNum = int.parse(bRest);
      return aNum.compareTo(bNum);
    }

    return aRest.compareTo(bRest);
  }
}
