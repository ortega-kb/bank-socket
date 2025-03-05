class SocketResponse {
  final String status;
  final dynamic data;

  const SocketResponse({required this.status, required this.data});

  factory SocketResponse.fromJson(Map<String, dynamic> json) {
    return SocketResponse(status: json['status'], data: json['data']);
  }
}
