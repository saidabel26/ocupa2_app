/// Constantes de la API de Ocupa2
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';

  // Perfil
  static const String me = '/me';
  static const String meProfile = '/me/profile';
  static const String mePassword = '/me/password';

  // Subida de imágenes
  static const String uploads = '/uploads';

  // Catálogo
  static const String jobTypes = '/job-types';

  // Noticias / Videos
  static const String news = '/news';
  static const String videos = '/videos';

  // Ofertas
  static const String offers = '/offers';
  static const String meOffers = '/me/offers';

  // Aplicaciones
  static const String meApplications = '/me/applications';
  static const String applications = '/applications';

  // Pagos
  static const String payments = '/payments';
  static const String mePayments = '/me/payments';

  // Experiencias
  static const String meExperiences = '/me/experiences';

  // Contratos
  static const String meContracts = '/me/contracts';
}
