enum UserRole { player, referee, organizer, admin }

UserRole? userRoleFromString(String value) {
  switch (value.toUpperCase()) {
    case 'PLAYER':
      return UserRole.player;
    case 'REFEREE':
      return UserRole.referee;
    case 'ORGANIZER':
      return UserRole.organizer;
    case 'ADMIN':
      return UserRole.admin;
    default:
      return null;
  }
}
