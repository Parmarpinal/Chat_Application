class UserProfile{
  String? uid;
  String? name;
  String? imgUrl;

  UserProfile({
    required this.uid,required this.name,required this.imgUrl
});

  UserProfile.fromJson(Map<String, dynamic> m){
    uid = m['uid'];
    name = m['name'];
    imgUrl = m['imgUrl'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = {};
    data['uid'] = uid;
    data['name'] = name;
    data['imgUrl'] = imgUrl;
    return data;
  }
}