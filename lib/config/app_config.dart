const gatewayUrl = String.fromEnvironment(
  'GATEWAY_URL',
  defaultValue: 'https://api-gateway-1050273358137.europe-central2.run.app',
);

const wsUrl = String.fromEnvironment(
  'WS_URL',
  defaultValue: 'wss://api-gateway-1050273358137.europe-central2.run.app/ws',
);

// const gatewayUrl = String.fromEnvironment(
//   'GATEWAY_URL',
//   defaultValue: 'http://localhost:8080',
// );

// const wsUrl = String.fromEnvironment(
//   'WS_URL',
//   defaultValue: 'ws://localhost:8080/ws',
// );
