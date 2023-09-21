String replaceAt(String string, String letter, int index) {
  return string.substring(0, index) + letter + string.substring(index + 1, string.length);
}