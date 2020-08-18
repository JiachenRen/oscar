class Term {
  final String optionValue;
  final String name;

  Term(this.optionValue, this.name);

  @override
  String toString() {
    return '<$name ($optionValue)>';
  }
}