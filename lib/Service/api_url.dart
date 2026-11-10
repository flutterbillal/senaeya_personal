class ApiConstant {
  // "https://api.senaeya.net/api/v1"
  // "http://10.10.7.77:8002/api/v1"
  //https://api-v2.senaeya.net
  static const baseUrl =
      "https://api-v2.senaeya.net/api/v1"; //This is local url
  static const imageBaseUrl = "https://api-v2.senaeya.net"; //This is local url
  // static const imageBaseUrl = "http://10.10.7.103:7010/api/v1"; //This is local url
  static const socketUrl = "https://api-v2.senaeya.net";
  // static const socketUrl = "http://158.252.71.185:7010";

  ///<=================================== For Auth part ====================>
  static const allMemes = "/get_memes";
  static const login = "/auth/workshop/login";
  static const loginWithFinger = "/auth/login-with-finger-print";
  static const register = "/users";
  static const forgetPassword = "/auth/forget-password";
  static const verifyEmail = "/auth/verify-email";
  static const resetPassword = "/auth/reset-password";
  static const changePassword = "/auth/change-password";
  static const resendOtp = "/auth/resend-otp";
  static const getCars = "/cars";
  static String getAuthorized(var id) => "/auth/check-user-authority/$id";
  static const getCountries = "/car-brand-countries/unpaginated";
  static const workShopWork = "/works-categories/unpaginated";
  static const expenses = "/expenses";
  static const expensesMonth = "/expenses/monthly-yearly-expenses?month=";
  static const carBrands = "/car-brands";
  static const createClient = "/clients";
  static const getClientCustomer = "/clients/cars/provider";
  static const updateClient = "/clients/update-during-create";
  static String carModels(var id) => "/car-models/brand/$id";
  static const getSymbolUrl = "/images/unpaginated/car_symbol/";
  static const getClient = "/clients/cars/provider";
  static const getClientCarsWithProvider = "/clients/cars/provider-cars";
  static const createCar = "/cars";
  static const getWorks = "/works";
  static const getSubscriptionUrl = "/packages";
  static String prepareMoyasarPayment(var id) => "/moyasar/prepare/$id";
  static String verifyMoyasarPayment(var paymentId) =>
      "/moyasar/verify/$paymentId";
  static String moyasarPaymentStatus(var paymentId) =>
      "/moyasar/status/$paymentId";
  static String getClientByContactUrl(var id) =>
      "/clients/client-by-contact/$id";
  static String getWorkShopByContact(var id) => "/workshops/contact/$id";
  static String payInvoiceUrl(var id) => "/invoices/release-invoice/$id";
  static const termandConditon = "/rule/terms-and-conditions";
  static const appExplain = "/rule/app-explain";
  static const aboutUs = "/rule/about";
  static const workCategory = "/works-categories/unpaginated";
  static const sendWorkItems = "/message";
  static const getReport = "/reports";
  static const message = "/message";
  static const getInvoices = "/invoices";
  static const chekPhoneNumber = "/check-phone-number";
  static const createWorkShop = "/workshops";
  static const createUser = "/users";
  static const notification = "/notification";
  static const clientInvoicesUrl = "/clients/invoices";
  static String sendMessageToReceiveCar({required clientId}) =>
      "/clients/send-message-to-recieve-car/$clientId";
  static String defaulterList(var id) => "/clients/toggle-status/$id";

  static const getProfile = "/users/profile";
  static const verifyTaxNumber = "/workshops/is-workshop";
  static const updateProfile = "/users/profile";
  static const checkingWorkshopIsCreated = "/workshops/crn-mln-unn-tax";
  static const payment = "/payments";
  static getClientByCar(var id) => "/clients/provider/clients-by-carNumber/$id";
  static getSubscriptionDetails(var id) => "/subscription/get/$id";
  static getSubscriptionByWorkshopId(var id) =>
      "/subscription/details/workshop/$id";
  static const getSparePartsByCode = "/spare-parts";
  static getDiscountByCupon(var id) => "/coupon/try/$id";

  static const appVersion = "/settings/app-version";
  static const additionalUser = "/users/helper-user";
  static const createSubscription = "/subscription/create-subscription";
}
