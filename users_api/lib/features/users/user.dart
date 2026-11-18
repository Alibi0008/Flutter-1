typedef Company = ({String name, String catchPhrase});

class Geo {
  const Geo({required this.lat, required this.lng});

  /// The server sends lat / lng as strings ("-37.3159").
  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    lat: double.parse(json['lat'] as String),
    lng: double.parse(json['lng'] as String),
  );

  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {
    'lat': lat.toString(),
    'lng': lng.toString(),
  };

  @override
  String toString() => 'Geo($lat, $lng)';
}

class Address {
  const Address({
    required this.street,
    required this.suite,
    required this.city,
    required this.zipcode,
    required this.geo,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json['street'] as String,
    suite: json['suite'] as String,
    city: json['city'] as String,
    zipcode: json['zipcode'] as String,
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
  );

  final String street;
  final String suite;
  final String city;
  final String zipcode;
  final Geo geo;

  Map<String, dynamic> toJson() => {
    'street': street,
    'suite': suite,
    'city': city,
    'zipcode': zipcode,
    'geo': geo.toJson(),
  };

  @override
  String toString() => 'Address($street, $suite, $city, $zipcode, $geo)';
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.address,
    required this.company,
  });

  /// A user the form builds before the server assigns an id.
  factory User.draft({
    required String name,
    required String username,
    required String email,
  }) => User(
    id: 0,
    name: name,
    username: username,
    email: email,
    phone: '',
    website: null,
    address: const Address(
      street: '',
      suite: '',
      city: '',
      zipcode: '',
      geo: Geo(lat: 0, lng: 0),
    ),
    company: (name: '', catchPhrase: ''),
  );

  /// Every cast is a claim. A wrong one throws a TypeError naming the field.
  factory User.fromJson(Map<String, dynamic> json) {
    final c = json['company'] as Map<String, dynamic>;
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String?,
      address: Address.fromJson(json['address'] as Map<String, dynamic>),
      company: (
        name: c['name'] as String,
        catchPhrase: c['catchPhrase'] as String,
      ),
    );
  }

  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String? website;
  final Address address;
  final Company company;

  /// Raw phone is kept; this strips everything but digits and '+'.
  String get phoneDigits => phone.replaceAll(RegExp(r'[^\d+]'), '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'email': email,
    'address': address.toJson(),
    'phone': phone,
    'website': website,
    'company': {'name': company.name, 'catchPhrase': company.catchPhrase},
  };

  @override
  bool operator ==(Object other) => other is User && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'User($id, $name, @$username, $email, '
      '${address.city}, $phoneDigits, ${website ?? '-'}, ${company.name})';
}
