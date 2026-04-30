const gatewayUrl = String.fromEnvironment(
  'GATEWAY_URL',
  defaultValue: 'http://localhost:8080',
);

const playerServiceUrl = String.fromEnvironment(
  'PLAYER_URL',
  defaultValue: 'http://localhost:8082',
);

const tournamentServiceUrl = String.fromEnvironment(
  'TOURNAMENT_URL',
  defaultValue: 'http://localhost:8084',
);

const arenaServiceUrl = String.fromEnvironment(
  'ARENA_URL',
  defaultValue: 'http://localhost:8083',
);

const authServiceUrl = String.fromEnvironment(
  'AUTH_URL',
  defaultValue: 'http://localhost:8081',
);

const matchServiceUrl = String.fromEnvironment(
  'MATCH_URL',
  defaultValue: 'http://localhost:8085',
);
