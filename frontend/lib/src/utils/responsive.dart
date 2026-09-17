abstract final class Breakpoints {
  static const mobile = 700.0;
  static const desktop = 1100.0;

  static int productColumns(double width) {
    if (width >= 1500) return 4;
    if (width >= desktop) return 3;
    if (width >= mobile) return 2;
    return 2;
  }
}
