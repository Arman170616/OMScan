class L10n {
  final bool ar;
  const L10n(this.ar);

  // Common
  String get cancel => ar ? 'إلغاء' : 'Cancel';
  String get delete => ar ? 'حذف' : 'Delete';
  String get edit => ar ? 'تعديل' : 'Edit';
  String get required => ar ? 'مطلوب' : 'Required';
  String get nameRequired => ar ? 'الاسم مطلوب' : 'Name required';
  String get invalid => ar ? 'غير صحيح' : 'Invalid';
  String get pcs => ar ? 'قطعة' : 'pcs';
  String get outOfStock => ar ? 'نفذ' : 'Out';
  String get connect => ar ? 'اتصال' : 'Connect';
  String get disconnect => ar ? 'قطع الاتصال' : 'Disconnect';
  String get categoryLabel => ar ? 'الفئة' : 'Category';
  String get productNameLabel => ar ? 'اسم المنتج' : 'Product Name';
  String get priceLabel => ar ? 'السعر (OMR)' : 'Price (OMR)';
  String get stockLabel => ar ? 'المخزون' : 'Stock';

  // Scanner
  String get scanPrompt =>
      ar ? 'وجه الكاميرا نحو الباركود' : 'Point camera at a barcode';
  String get cartHeader => ar ? 'المنتجات المضافة' : 'Scanned Items';
  String get scanEmpty => ar ? 'امسح منتجاً للبدء' : 'Scan a product to start';
  String get reviewOrder => ar ? 'مراجعة الطلب' : 'Review Order';
  String addedToCart(String name) => ar ? '$name تمت الإضافة' : '$name added';

  // Add product sheet
  String get newProduct => ar ? 'منتج جديد' : 'New Product';
  String get productNameRequired => ar ? 'اسم المنتج *' : 'Product Name *';
  String get productNameHint =>
      ar ? 'مثال: عصير برتقال' : 'e.g. Orange Juice';
  String get priceRequired => ar ? 'السعر (OMR) *' : 'Price (OMR) *';
  String get initialStock => ar ? 'المخزون الأولي' : 'Initial Stock';
  String get saveAndAdd =>
      ar ? 'حفظ وإضافة للسلة' : 'Save & Add to Cart';

  // Inventory
  String get inventory => ar ? 'المخزون' : 'Inventory';
  String itemCount(int n) => ar ? '$n منتج' : '$n items';
  String get inStock => ar ? 'متوفر' : 'In Stock';
  String get lowStock => ar ? 'منخفض' : 'Low';
  String get outStock => ar ? 'نفذ' : 'Out';
  String get searchHint =>
      ar ? 'البحث بالاسم أو الباركود...' : 'Search by name or barcode...';
  String get noProducts =>
      ar ? 'لا توجد منتجات\nامسح باركود لإضافة منتج' : 'No products yet\nScan a barcode to add';
  String get noResults => ar ? 'لا توجد نتائج' : 'No results found';
  String get restock => ar ? 'إعادة تخزين' : 'Restock';
  String get deleteProduct => ar ? 'حذف المنتج؟' : 'Delete Product?';
  String deleteConfirm(String name) =>
      ar ? 'هل تريد حذف "$name" من المخزون؟' : 'Remove "$name" from inventory?';
  String get currentStock => ar ? 'المخزون الحالي: ' : 'Current stock: ';
  String get qtyToAdd => ar ? 'الكمية المضافة' : 'Qty to Add';
  String get addStock => ar ? 'إضافة للمخزون' : 'Add Stock';
  String get editProduct => ar ? 'تعديل المنتج' : 'Edit Product';
  String get categoryHint =>
      ar ? 'الفئة تحدد الأيقونة' : 'Category sets the icon';
  String get saveChanges => ar ? 'حفظ التغييرات' : 'Save Changes';

  // Dashboard
  String get dashboard => ar ? 'لوحة التحكم' : 'Dashboard';
  String get periodWeek => ar ? 'أسبوع' : 'Week';
  String get periodMonth => ar ? 'شهر' : 'Month';
  String get periodYear => ar ? 'سنة' : 'Year';
  List<String> get periods => [periodWeek, periodMonth, periodYear];
  String revenue(String period) =>
      ar ? 'إيرادات $period' : '$period Revenue';
  String get orders => ar ? 'الطلبات' : 'Orders';
  String get avgOrder => ar ? 'متوسط الطلب' : 'Avg Order';
  String get salesOverview =>
      ar ? 'نظرة عامة على المبيعات' : 'Sales Overview';
  String noSales(String period) =>
      ar ? 'لا توجد مبيعات هذا $period' : 'No sales this $period';
  String get recentOrders => ar ? 'آخر الطلبات' : 'Recent Orders';
  String orderCount(int n) => ar ? '$n طلب' : '$n orders';
  String get noOrders => ar ? 'لا توجد طلبات بعد' : 'No orders yet';
  List<String> get weekLabels => ar
      ? ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح']
      : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  String weekPrefix(int w) => ar ? 'أ$w' : 'W$w';

  // Checkout
  String get checkout => ar ? 'الدفع' : 'Checkout';
  String get productCol => ar ? 'المنتج' : 'Product';
  String get priceCol => ar ? 'السعر' : 'Price';
  String get totalCol => ar ? 'الإجمالي' : 'Total';
  String get total => ar ? 'الإجمالي' : 'Total';
  String get scanToPay => ar ? 'امسح للدفع' : 'Scan to Pay';
  String get paymentMethod => ar ? 'طريقة الدفع' : 'Payment Method';
  String printerReady(String name) =>
      ar ? '$name  •  جاهز' : '$name  •  Ready';
  String get noPrinter => ar ? 'لا يوجد طابعة متصلة' : 'No printer connected';
  String get confirmPayment =>
      ar ? 'تأكيد الدفع والطباعة' : 'Confirm Payment & Print';
  String get paymentConfirmed => ar ? 'تم تأكيد الدفع!' : 'Payment Confirmed!';
  String get printSuccess => ar ? 'تمت الطباعة بنجاح' : 'Printed successfully';
  String get connectPrinterMsg =>
      ar ? 'قم بتوصيل طابعة لطباعة الفاتورة' : 'Connect a printer to print receipt';
  String get printing => ar ? 'جارٍ الطباعة...' : 'Printing...';
  String get printReceipt => ar ? 'طباعة الفاتورة' : 'Print Receipt';
  String get downloadInvoice =>
      ar ? 'تحميل الفاتورة (PDF)' : 'Download Invoice (PDF)';
  String get newTransaction => ar ? 'معاملة جديدة' : 'New Transaction';

  // Payment methods
  String get methodQris => ar ? 'رمز QR' : 'QRIS';
  String get methodCard => ar ? 'بطاقة' : 'Card';
  String get methodCash => ar ? 'نقد' : 'Cash';
  String get methodBank => ar ? 'تحويل بنكي' : 'Bank Transfer';
  List<String> get paymentMethods =>
      [methodQris, methodCard, methodCash, methodBank];
  static const List<String> methodKeys = ['QRIS', 'Card', 'Cash', 'Bank Transfer'];
}
