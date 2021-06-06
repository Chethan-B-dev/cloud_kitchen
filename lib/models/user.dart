class User {
  final String id;
  final String username;
  final String email;
  final String address;
  final String phone;
  final bool isSeller;

  User(this.id, this.username, this.email, this.address, this.phone,
      this.isSeller);

  void display() {
    print("test");
  }
}
