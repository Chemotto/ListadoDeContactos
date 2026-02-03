# App de Contactos – Informe de funcionalidades y requisitos

## Descripción general
Esta aplicación implementa un flujo de acceso y gestión de contactos combinando datos locales y remotos. Tras el login, el usuario puede ver una lista de contactos obtenidos de una API REST y añadir contactos locales que quedan persistidos entre sesiones. Incluye edición/borrado de contactos locales, búsqueda, y navegación a detalle.

## Estructura de pantallas (ViewControllers)
- LoginViewController
  - Pantalla de acceso con validación de usuario y gestión de sesión con UserDefaults.
  - Presenta el flujo principal de contactos tras iniciar sesión.
- ContactsViewController
  - Lista (UITableView) de contactos combinados (locales + remotos), con búsqueda (UISearchController), botón flotante para añadir, menú en NavigationItem y soporte de edición/borrado para locales.
  - Muestra diálogos (UIAlertController) para añadir y editar/borrar contactos locales.
- ContactDetailViewController
  - Pantalla de detalle que muestra la información completa de un contacto.
  - Incluye un UIScrollView para permitir el scroll del contenido.

Con esto se cumplen los 3+ ViewControllers requeridos.

## Cumplimiento de requisitos de la práctica
- 3+ ViewControllers: LoginViewController, ContactsViewController y ContactDetailViewController.
- Paso de parámetro entre ViewControllers: desde ContactsViewController se pasa el `Contact` seleccionado a ContactDetailViewController (propiedad `contact`), donde se recupera y usa para poblar la UI.
- Diálogo (UIAlertController): uso de alertas para añadir y editar/borrar contactos locales, además de mensajes de error.
- Sistema de sesión (UserDefaults): `SessionManager` guarda el usuario logueado y `LoginViewController` gestiona el acceso en función de ese estado.
- API REST con URLSession: `APIClient` obtiene contactos remotos desde `https://jsonplaceholder.typicode.com/users`.
- UITableView: `ContactsViewController` muestra la lista, maneja selección (navega al detalle) y soporta swipe-to-delete en contactos locales.
- Menú en NavigationItem: botón de acción en `ContactsViewController` con opciones (Acerca de, Cerrar sesión) presentado como actionSheet.
- UIScrollView: presente en `ContactDetailViewController` para el contenido de detalle.

## Búsqueda (extra)
- `ContactsViewController` integra un `UISearchController` para filtrar por Nombre, Teléfono, Email y Web en tiempo real.

## Persistencia de contactos locales
- Los contactos locales se guardan en `UserDefaults` como JSON (`LocalContact: Codable`) y se muestran antes que los remotos.
- Se asigna un identificador estable (UUID) a cada contacto local para permitir edición y borrado preciso.

## Cómo ejecutar
1. Abrir el proyecto en Xcode.
2. Asegurar que el Storyboard ID “ContactsNavigationController” apunte a un UINavigationController cuyo root sea `ContactsViewController`.
3. Ejecutar la app en un simulador o dispositivo.
4. Introducir un nombre de usuario en la pantalla de login y pulsar “Entrar”.

## Notas finales
- El proyecto ha sido limpiado para eliminar flujos alternativos no utilizados, centrando la experiencia en `ContactsViewController` + `ContactDetailViewController`.
- Se puede ampliar la persistencia a Core Data/SwiftData o añadir exportación/importación de contactos locales como mejora futura.

