/// Punto de extensión para autorización por rol.
///
/// En esta etapa de modelado permite siempre el acceso. Cuando exista
/// autenticación, aquí se evaluarán los permisos antes de abrir cada módulo.
class DemoAccessGuard {
  const DemoAccessGuard();

  bool canOpen(String route) => true;
}
