**Plan de implementación**

Los estados representarán exclusivamente el pago:

- `pending`: `paid_amount == 0`
- `partial`: `0 < paid_amount < total`
- `paid`: `paid_amount == total`

Todo pago deberá cumplir:

$$0 < \text{pago} \leq \text{total} - \text{paid\_amount}$$

### 1. Fortalecer base de datos

Crear una migración para:

- Cambiar importes monetarios de `float` a `decimal`.
- Establecer `orders.paid_amount` con `default: 0`, `null: false`.
- Hacer obligatorios `orders.total`, `orders.status`, `order_products.price`, `order_products.quantity` y `payments.quantity`.
- Establecer `orders.status` por defecto como `pending`.
- Agregar índice único a `order_payments(payment_id, order_id)`.
- Agregar índice único a `order_products(order_id, product_id)`.
- Incorporar restricciones positivas para totales, precios, cantidades y pagos.

### 2. Corregir asociaciones

En `Order`:

- Cambiar `has_one :alumn` por `belongs_to :alumn`.
- Agregar `has_many :order_products`.
- Agregar `has_many :products, through: :order_products`.
- Definir una política de eliminación para productos y pagos asociados.

En `Product`:

- Agregar `has_many :order_products`.
- Usar `has_many :orders, through: :order_products`.

### 3. Centralizar reglas en `Order`

Agregar al modelo:

- Validaciones de presencia y valores positivos.
- `remaining_balance`.
- `recalculate_payment_status!`.
- `register_payment!(payment)`, responsable de:
  - Bloquear la orden durante la operación.
  - Rechazar pagos en órdenes ya pagadas.
  - Rechazar cantidades mayores al saldo.
  - Crear `OrderPayment`.
  - Actualizar `paid_amount`.
  - Calcular el estado correspondiente.

El controlador no debería decidir directamente el estado.

### 4. Robustecer la creación de órdenes

Refactorizar `OrdersController#create` para que:

1. Valide que exista al menos un producto.
2. Cargue los productos desde la base de datos.
3. Ignore precios y total enviados por el frontend.
4. Calcule cada subtotal con el precio almacenado.
5. Calcule el total en el servidor.
6. Cree orden y renglones dentro de una transacción.
7. Si existe adelanto, lo registre mediante la misma lógica utilizada por los pagos posteriores.
8. Revierta toda la operación ante cualquier error.
9. Devuelva errores estructurados y comprensibles.

Los métodos auxiliares deben usar `create!`/`update!` y ser privados.

### 5. Robustecer pagos posteriores

En `PaymentsController`:

- Validar siempre `payable_type` y `payable_id`.
- Para órdenes, delegar en `order.register_payment!`.
- Usar `quantity`, no parámetros derivados como `paid_amount`.
- Rechazar pago cero, negativo o mayor al saldo.
- Utilizar una transacción con bloqueo para evitar pagos simultáneos incorrectos.
- Usar `create!` y `update!` para garantizar rollback.
- Devolver `422` con el saldo disponible cuando el pago sea inválido.

También hay que corregir la validación de `Payment`, que actualmente consulta `amount` aunque la columna se llama `quantity`.

### 6. Definir edición y eliminación de pagos

Para mantener consistencia operativa, la primera versión debería:

- Impedir editar un pago asociado a una orden.
- Impedir eliminar un pago asociado a una orden.

Modificar pagos históricos exige recalcular monto y estado, por lo que es más seguro no permitirlo mientras no exista un flujo explícito de corrección administrativa.

### 7. Completar respuestas del API

El `index` y `show` de órdenes deberían incluir:

- Alumno.
- `order_products` con producto, cantidad y precio histórico.
- `total`.
- `paid_amount`.
- `remaining_balance`.
- `status`.
- Historial de pagos, al menos en `show`.
- Paginación y filtros por estado/alumno.

Conviene devolver el enum como nombre (`pending`, `partial`, `paid`), no como número.

### 8. Completar formulario frontend

Corregir y agregar:

- Rutas `/dashboard/orders` y `/dashboard/orders/form`.
- Validación de alumno seleccionado.
- Requerir al menos un producto.
- Validar cantidades enteras mayores que cero.
- Permitir eliminar productos individualmente.
- Tratar anticipo vacío como cero, evitando `NaN`.
- Impedir anticipo negativo o mayor al total.
- No enviar precios ni total como fuente confiable; pueden enviarse solo como referencia visual.
- Mostrar errores del backend.
- Evitar doble envío mientras la petición está en curso.

### 9. Completar tabla y flujo de pago

La tabla debería mostrar:

- Alumno.
- Total.
- Pagado.
- Saldo.
- Estado.
- Fecha.
- Acciones para ver detalle, pagos y registrar pago.

Crear un formulario/modal de pago que:

- Muestre total, pagado y saldo.
- Limite el importe al saldo.
- Envíe `payable_type: "order"` y `payable_id`.
- Actualice la orden después del pago.
- Deshabilite el pago cuando el estado sea `paid`.

### 10. Pruebas necesarias

Cubrir como mínimo:

- Orden sin anticipo → `pending`.
- Orden con anticipo menor al total → `partial`.
- Orden con anticipo exacto → `paid`.
- Pago posterior parcial.
- Pago posterior que completa la orden.
- Rechazo de pago mayor al saldo.
- Rechazo de pago cero o negativo.
- Rechazo de pago a una orden pagada.
- Total calculado desde productos del servidor.
- Rollback si falla un producto o pago.
- Protección ante dos pagos simultáneos.
- Asociaciones y eliminación según la política elegida.
- Validaciones del formulario frontend.

**Orden recomendado**

1. Migración y asociaciones.
2. Reglas de negocio en `Order`.
3. Refactor de creación y pagos.
4. Tests backend.
5. Respuestas del API.
6. Formulario frontend.
7. Tabla, detalle e ingreso de pagos.
8. Tests frontend y validación integral del flujo.