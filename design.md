# Design Spec — Journaly Wallet App

Especificación de diseño extraída de capturas de referencia de una app fintech/wallet (usuario de ejemplo "Sullivan"). Este documento sirve como guía visual y de componentes para implementar la UI en Flutter.

## 1. Overview

App de billetera digital con 3 flujos principales:
- **Home**: resumen de cuentas, tarjeta destacada y cajeros cercanos.
- **Super Card**: listado y gestión de tarjetas del usuario.
- **Send/Pay**: envío de dinero, recarga y solicitud de pago a contactos.

Estilo visual: minimalista, fondo claro, tarjetas con esquinas muy redondeadas, acentos de color por tarjeta/cuenta, tipografía sans-serif limpia.

## 2. Design Tokens

**Colores**
- Fondo general: blanco / gris muy claro (`#FFFFFF` / `#F7F7F9`)
- Tarjeta oscura (principal): negro/gris carbón (`#1E1E1E` – `#2A2A2A`)
- Tarjeta acento naranja: (`#F4A97A` – `#E88A5C`) con patrón sutil
- Tarjeta acento celeste: (`#CFE0EC` – `#D9E8F0`)
- Texto primario: negro/gris oscuro (`#1A1A1A`)
- Texto secundario: gris medio (`#8A8A8E`)
- Acento de estado/favorito: amarillo/naranja para estrella activa
- Iconos inactivos (nav bar): gris claro; icono activo: negro con contenedor circular

**Tipografía**
- Saludo ("Hi, Sullivan!"): grande, semi-bold (~22-24sp)
- Montos/balances: bold, tamaño mediano-grande (~18-20sp)
- Labels de sección ("Super Card", "Super ATM"): semi-bold (~16sp)
- Texto secundario (emails, subtítulos): regular, pequeño (~12-13sp), color gris

**Forma y espaciado**
- Radio de esquina de tarjetas: muy alto (~20-24px), aspecto "pill" en extremos
- Padding de pantalla: ~16-20px horizontal
- Separación entre secciones: ~24px

**Iconografía**
- Iconos outline simples para bottom nav y elementos de lista
- Logos de marca (Visa, Paypal, Amazon) dentro de tarjetas/tiles

## 3. Componentes reutilizables

### `BottomNavBar`
Barra inferior fija, 5 items, icono activo resaltado en círculo negro:
1. Home (casa)
2. Cards (tarjeta) — resaltado como activo en la captura de Super Card
3. Scan/QR (icono central, cuadrado con esquinas)
4. Transfer (flechas cruzadas) — resaltado como activo en Send/Pay
5. Settings (engranaje)

### `SummaryTile`
Usado en Home para "Paypal Income" y "Amazon Shop":
- Icono de marca en esquina superior
- Label pequeño (ej. "Paypal Income")
- Monto en bold debajo (ej. "$ 1,260.28")
- Fondo gris claro, esquinas redondeadas, dos tiles en fila (grid 2 columnas)

### `CreditCardWidget`
Tarjeta con variantes de color (oscura, naranja, celeste):
- Marca arriba a la izquierda ("VISA" con check de verificado, o icono de tarjeta genérica)
- Fecha de expiración arriba a la derecha (ej. "08/28")
- Balance grande centrado-izquierda (ej. "$1,260.28")
- Número enmascarado abajo (ej. "•••• •••• •••• 7735")
- Usado tanto en Home (una sola, sección "Super Card") como en la pantalla de listado (varias, apiladas verticalmente)

### `SectionHeader`
Título de sección + chevron ">" a la derecha, indica navegación a vista detallada (ej. "Super Card >", "Super ATM >")

### `ContactListItem`
Usado en Send/Pay:
- Avatar circular (foto)
- Nombre (bold) + email (gris, pequeño) apilados
- Icono de estrella a la derecha (llena/naranja si es favorito, outline si no)

### `SearchBar`
Campo de búsqueda con placeholder "Search contact" e icono de lupa a la derecha, esquinas muy redondeadas.

### `SegmentedTabs`
Tabs superiores tipo pestaña con subrayado en la activa: "Send/Pay | Top Up | Request"

## 4. Pantallas

### 4.1 Home Screen
De arriba a abajo:
1. Header: "Hi, Sullivan!" + icono de menú hamburguesa
2. Fila de 2 `SummaryTile`: Paypal Income, Amazon Shop
3. `SectionHeader` "Super Card" + un `CreditCardWidget` (variante oscura)
4. `SectionHeader` "Super ATM" + mapa con pines de ubicación de cajeros (2 pines visibles)
5. `BottomNavBar` (Home activo)

### 4.2 Super Card Screen (listado de tarjetas)
De arriba a abajo:
1. Header: "Super Card" + icono de menú
2. Lista vertical de `CreditCardWidget`, una por tarjeta:
   - Visa oscura — $1,260.28 — •••7735
   - Tarjeta naranja (genérica, ícono de círculos superpuestos) — $1,180.49 — •••7998
   - Visa celeste — $865.39 — •••7782
3. Botón "+ Add Card" (outline, ancho completo, debajo de la lista)
4. `BottomNavBar` (Cards activo)

### 4.3 Send/Pay Screen
De arriba a abajo:
1. `SegmentedTabs`: Send/Pay (activo) | Top Up | Request
2. `SearchBar` "Search contact"
3. Sección "Last Transaction": lista horizontal o vertical corta de `ContactListItem` (contactos recientes, con favoritos marcados)
4. Sección "All Contact": lista vertical completa de `ContactListItem`, orden alfabético/por relevancia
5. `BottomNavBar` (Transfer activo)

## 5. Navegación

- `BottomNavBar` es persistente en las 3 pantallas; cambia el ítem resaltado según la pantalla activa.
- Desde Home, el `SectionHeader` "Super Card" (chevron) navega a la pantalla de listado de tarjetas (4.2).
- El icono de transferencia en `BottomNavBar` navega a Send/Pay (4.3), que por defecto abre en el tab "Send/Pay"; los tabs "Top Up" y "Request" son vistas hermanas dentro de la misma pantalla (cambian el contenido bajo la búsqueda, no toda la pantalla).
- El icono central de scan/QR probablemente abre una vista de cámara/escaneo de código (no capturada en las imágenes de referencia).

## 6. Notas de implementación (Flutter)

- El proyecto es Flutter (ver [lib/main.dart](lib/main.dart)); actualmente solo contiene el scaffold por defecto (`MyApp` / `MyHomePage`), sin ninguna UI implementada.
- Sugerencia de estructura de widgets al implementar:
  - `lib/widgets/bottom_nav_bar.dart`
  - `lib/widgets/credit_card_widget.dart`
  - `lib/widgets/summary_tile.dart`
  - `lib/widgets/contact_list_item.dart`
  - `lib/screens/home_screen.dart`
  - `lib/screens/cards_screen.dart`
  - `lib/screens/send_pay_screen.dart`
- Colores y radios de esquina se pueden centralizar en un `ThemeData`/`AppColors` propio en vez del `deepPurple` seed actual.
- Este documento no incluye código; es referencia de diseño para guiar la implementación posterior.
