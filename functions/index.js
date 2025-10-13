const { onCall } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const Stripe = require("stripe");

setGlobalOptions({ 
  maxInstances: 10,
  region: 'us-central1'
});

exports.createPaymentIntent = onCall(async (request) => {
  try {
    console.log("✅ createPaymentIntent ejecutándose");
    
    const { amount, currency = "mxn" } = request.data;
    console.log("📦 Datos recibidos:", { amount, currency });

    // Validaciones
    if (!amount || amount <= 0) {
      throw new functions.https.HttpsError('invalid-argument', 'El monto debe ser un número positivo');
    }

    // Verificar que STRIPE_SECRET existe
    if (!process.env.STRIPE_SECRET) {
      console.error("❌ STRIPE_SECRET no está definido");
      throw new functions.https.HttpsError('internal', 'Error de configuración del servidor');
    }

    // Inicializar Stripe aquí mismo
    const stripe = new Stripe(process.env.STRIPE_SECRET, { 
      apiVersion: "2024-04-10"
    });

    console.log(`🔄 Creando PaymentIntent: ${amount} ${currency}`);

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount),
      currency: currency.toLowerCase(),
      payment_method_types: ["card"],
    });

    console.log("✅ PaymentIntent creado:", paymentIntent.id);

    return {
      success: true,
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id
    };

  } catch (error) {
    console.error("❌ Error en createPaymentIntent:", error);
    
    // Manejar errores específicos de Stripe
    let errorMessage = 'Error procesando el pago';
    let errorCode = 'internal';

    if (error.type) {
      switch (error.type) {
        case 'StripeCardError':
          // Errores de tarjeta
          switch (error.code) {
            case 'card_declined':
              errorMessage = 'Tu tarjeta fue rechazada. Por favor usa otra tarjeta.';
              errorCode = 'failed-precondition';
              break;
            case 'expired_card':
              errorMessage = 'Tu tarjeta está expirada. Por favor usa otra tarjeta.';
              errorCode = 'failed-precondition';
              break;
            case 'insufficient_funds':
              errorMessage = 'Fondos insuficientes en la tarjeta.';
              errorCode = 'failed-precondition';
              break;
            case 'invalid_cvc':
              errorMessage = 'El código CVC es inválido.';
              errorCode = 'invalid-argument';
              break;
            case 'incorrect_number':
              errorMessage = 'El número de tarjeta es incorrecto.';
              errorCode = 'invalid-argument';
              break;
            case 'incorrect_zip':
              errorMessage = 'El código postal es incorrecto.';
              errorCode = 'invalid-argument';
              break;
            default:
              errorMessage = `Error de tarjeta: ${error.message}`;
              errorCode = 'failed-precondition';
          }
          break;

        case 'StripeInvalidRequestError':
          // Errores de solicitud inválida
          errorMessage = 'Información de pago inválida. Verifica los datos.';
          errorCode = 'invalid-argument';
          break;

        case 'StripeAPIError':
          // Error del API de Stripe
          errorMessage = 'Error temporal del servicio de pagos. Intenta nuevamente.';
          errorCode = 'unavailable';
          break;

        case 'StripeConnectionError':
          // Error de conexión
          errorMessage = 'Error de conexión con el servicio de pagos.';
          errorCode = 'unavailable';
          break;

        case 'StripeRateLimitError':
          // Demasiadas solicitudes
          errorMessage = 'Demasiadas solicitudes. Espera un momento e intenta nuevamente.';
          errorCode = 'resource-exhausted';
          break;

        case 'StripeAuthenticationError':
          // Error de autenticación (clave inválida)
          errorMessage = 'Error de configuración del servicio de pagos.';
          errorCode = 'internal';
          break;

        default:
          // Error genérico de Stripe
          errorMessage = `Error del servicio de pagos: ${error.message}`;
          errorCode = 'internal';
      }
    } else {
      // Error no relacionado con Stripe
      errorMessage = `Error del servidor: ${error.message}`;
      errorCode = 'internal';
    }

    throw new functions.https.HttpsError(errorCode, errorMessage);
  }
});