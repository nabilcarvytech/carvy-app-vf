class DashBoardHost {
  int? status;
  String? message;
  DataWrapper? data;
  String? error;

  DashBoardHost({this.status, this.message, this.data, this.error});

  DashBoardHost.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? DataWrapper.fromJson(json['data']) : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['error'] = error;
    return data;
  }
}

class DataWrapper {
  DashboardData? data;

  DataWrapper({this.data});

  DataWrapper.fromJson(Map<String, dynamic> json) {
    // Le backend retourne maintenant directement les données du dashboard dans 'data'
    // sans niveau supplémentaire, donc on crée DashboardData directement depuis json
    data = DashboardData.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class DashboardData {
  dynamic totalSales;
  dynamic? todayOrders;
  dynamic? newProducts;
  dynamic? pendingOrders;
  dynamic? confirmedOrders;
  dynamic? cancelledOrders;
  dynamic? weeklyTotalBookings; 
  dynamic? weeklyTotalEarnings;
  WeeklyIncomeReport? weeklyIncomeReport; 

  DashboardData({
    this.totalSales,
    this.todayOrders,
    this.newProducts,
    this.pendingOrders,
    this.confirmedOrders,
    this.cancelledOrders,
    this.weeklyTotalBookings,
    this.weeklyTotalEarnings,
    this.weeklyIncomeReport,
  });

  DashboardData.fromJson(Map<String, dynamic> json) {
    totalSales = json['total_sales'];
    todayOrders = json['today_orders'];
    // Support pour total_items (Node.js) et new_products (ancien format) pour compatibilité
    newProducts = json['total_items'] ?? json['new_products'];
    pendingOrders = json['pending_orders'];
    confirmedOrders = json['confirmedOrders'];
    cancelledOrders = json['cancelledOrders'];
    weeklyTotalBookings = json['weekly_total_bookings']; 
    weeklyTotalEarnings = json['weekly_total_earnings']; 
    weeklyIncomeReport = json['weekly_income_report'] != null
        ? WeeklyIncomeReport.fromJson(json['weekly_income_report'])
        : null; 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_sales'] = totalSales;
    data['today_orders'] = todayOrders;
    data['new_products'] = newProducts;
    data['pending_orders'] = pendingOrders;
    data['confirmedOrders'] = confirmedOrders;
    data['cancelledOrders'] = cancelledOrders;
    data['weekly_total_bookings'] = weeklyTotalBookings;
    data['weekly_total_earnings'] = weeklyTotalEarnings; 
    if (weeklyIncomeReport != null) {
      data['weekly_income_report'] = weeklyIncomeReport!.toJson(); 
    }
    return data;
  }
}

class WeeklyIncomeReport {
  num? monday;
  num? tuesday;
  num? wednesday;
  num? thursday;
  num? friday;
  num? saturday;
  num? sunday;

  WeeklyIncomeReport({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  WeeklyIncomeReport.fromJson(Map<String, dynamic> json) {
    monday = json['monday'];
    tuesday = json['tuesday'];
    wednesday = json['wednesday'];
    thursday = json['thursday'];
    friday = json['friday'];
    saturday = json['saturday'];
    sunday = json['sunday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['monday'] = monday;
    data['tuesday'] = tuesday;
    data['wednesday'] = wednesday;
    data['thursday'] = thursday;
    data['friday'] = friday;
    data['saturday'] = saturday;
    data['sunday'] = sunday;
    return data;
  }
}