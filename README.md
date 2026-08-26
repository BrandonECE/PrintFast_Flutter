# PrintFast

Aplicación móvil que conecta a usuarios con papelerías para servicios de impresión. El usuario sube sus documentos, elige una papelería, paga en la app y sigue su pedido en tiempo real hasta recogerlo.

<!-- Sube aquí una captura principal o un GIF de la app -->
<img width="278" height="617" alt="att 3cv4iO1FZ-6JwwlYKvVVgiV72f2OyL3E2e8W2l48Vks png" src="https://github.com/user-attachments/assets/78ea9e21-21c8-4619-8fea-9855566c98bf" />
<img width="278" height="617" alt="att 4OXw0GGGeiHHFfqwL7C7CT5uraeSGSwyixtl4deqtsI png" src="https://github.com/user-attachments/assets/df10bd48-dde0-4014-aaf3-d5608336201e" />
<img width="278" height="617" alt="att TeH8D1SkEc6j3l2IgIh5aKp70MvkF_R6bVjl0HJldyE png" src="https://github.com/user-attachments/assets/e3e43715-6c82-4772-b7f2-784d940939d5" />


## ¿Qué hace?

- **Sube y envía documentos:** el usuario carga sus PDFs desde la app y los envía a la papelería que elija para imprimir.
- **Aceptación por la papelería:** la papelería revisa el trabajo y lo acepta o lo rechaza; si lo rechaza, el usuario puede elegir otra.
- **Pago integrado:** cobro seguro dentro de la app mediante Stripe.
- **Seguimiento en vivo:** un mapa muestra el estado del pedido y cuánto falta para que esté listo para recoger en la papelería.
- **Dos roles:** cliente (envía y sigue sus impresiones) y administrador de papelería (gestiona los pedidos entrantes).

## Tecnologías

- **Flutter / Dart**
- **Clean Architecture** (capas domain / infrastructure / presentation)
- **BLoC** para la gestión de estado
- **GetIt** para inyección de dependencias
- **Firebase** (Firestore, Authentication) con datos en tiempo real vía **streams**
- **Cloud Functions** para lógica de servidor
- **Stripe** para procesamiento de pagos
- **Google Maps** para geolocalización y seguimiento
- Generación de **PDF**

## Arquitectura

El proyecto sigue Clean Architecture, separando la lógica en capas independientes (dominio, infraestructura y presentación) para mantener el código escalable y mantenible. La gestión de estado se maneja con BLoC, con blocs organizados por rol (administrador y usuario). Más de 36 pantallas.

## Capturas

Estas son solo algunas pantallas de la app.

### Cliente
| Inicio | Subir documento | Envío |
|--------|-----------------|-------|
| <img width="278" height="617" alt="att OYv_BE778-n983XlWRwCWXhvCmwWP_V-M-iv-Gp0yv8 png" src="https://github.com/user-attachments/assets/cff977c2-3ec0-4630-8bc5-2a6fc9b1cac3" /> | <img width="278" height="617" alt="att Hr2QjplGjxRjKNwcnSzmo_CEwKq6P87ZHEccVSYqqZ8 png" src="https://github.com/user-attachments/assets/c806588d-5787-4bff-8f97-9e333a2db0dc" /> | <img width="278" height="617" alt="att Ui54J4mBoGUIYtWfWe8hwCY4B0cmEOHPy2shcrardWw png" src="https://github.com/user-attachments/assets/6ffcab43-7ece-471a-a70b-2484c9d8f38e" />) |

| Envío  |      Pago       | Detalle de orden |
|--------|-----------------|------------------|
| <img width="278" height="617" alt="image" src="https://github.com/user-attachments/assets/634c9b5f-b8f3-4fa7-ab65-0eb98c80a199" /> | <img width="278" height="617" alt="att kwEio4uR4D9yDq5mOjnf3spssyT_akUraJLwgq9lh1M png" src="https://github.com/user-attachments/assets/2ccee5dd-ff2f-48a2-a89a-834420607aeb" /> |<img width="278" height="617" alt="att jVCSab0xzBuRF5YEJ7FL_iPqfmXmoEoRJ5ZE1slAssc png" src="https://github.com/user-attachments/assets/7220013c-3f81-45d0-b1eb-af01637353c4" />|

| Seguimiento  |      Código       | Entregado Exitosamente |
|--------------|-------------------|------------------------|
| <img width="278" height="617" alt="image (1)" src="https://github.com/user-attachments/assets/936c19d7-a642-4ed7-ad19-d525bb5816a8" /> | <img width="278" height="617" alt="att Tw0Ta97rvKvVlAJaYV1VFw_eci8fLdMSUoXTDdQtWWA png" src="https://github.com/user-attachments/assets/834bf208-c27c-4e97-b185-f6b06ac6ccf1" /> | <img width="278" height="617" alt="att iDxQ569l4rZOoo35qaYxkIa4VVgr6mPDM7cLpzP3Z6Q png" src="https://github.com/user-attachments/assets/7727d161-edfd-4e5b-a58c-257b98917899" />|

### Administrador (papelería)
| Órdenes |    Órdenes P.   |  Aceptar órdenes |
|---------|-----------------|------------------|
| <img width="278" height="617" alt="att qFkcMPmlOZGgG22KJnRWYhIlux72vw48OUIGyaziBZc png" src="https://github.com/user-attachments/assets/20394c51-caee-42c9-acaf-6dc117bfa119" /> | <img width="278" height="617" alt="att upSMu1lz-zUpcvVpdwjIwrlTIDfFkSm7sqikNoAeOns png" src="https://github.com/user-attachments/assets/212bcd3b-36c7-47ae-8d79-bc6aa9c84f3d" /> | <img width="278" height="617" alt="att Jv4YJ7DIHXA42WGl8PqF0GNGQR9x8Sz_UgcnSe3VxrM png" src="https://github.com/user-attachments/assets/e9274791-68d1-497c-9476-18d34c16b9d9" /> |


|  Detalle de orden |  Validación de código  | Entregado Exitosamente |
|-------------------|------------------------|------------------------|
| <img width="278" height="617" alt="att JXgTaf4miRs4Fvksg1acKl1KlhVo5H6rVGgiNwFBED4 png" src="https://github.com/user-attachments/assets/d88d8f2c-0f5b-428c-8a48-8823deba9035" /> | <img width="278" height="617" alt="att E1TSX-oyhuJ6B5N4FpyavhRB7Fl28NuOLkDxTSVPGPc png" src="https://github.com/user-attachments/assets/556077d8-bc8d-4126-9ea3-5644f1c20feb" /> | <img width="278" height="617" alt="att Iqw5NGlpKERHZ0vCUsfqQVaUS4KZl0krkAtDulr2Sq4 png" src="https://github.com/user-attachments/assets/904daefa-d037-4e8c-bbc7-5b1e2d3c0f9e" /> |

## Autor

**Brandon Cantú** — Desarrollador Flutter
🔗 [GitHub](https://github.com/BrandonECE)
💼 [LinkedIn](https://www.linkedin.com/in/brandoncantu-dev)
