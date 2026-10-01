class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String avatarUrl;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'avatar_url': avatarUrl,
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String? ?? 'user-${DateTime.now().millisecondsSinceEpoch}',
        name: json['name'] as String? ?? (json['full_name'] as String? ?? 'Member'),
        email: json['email'] as String? ?? '',
        role: json['role'] as String? ?? 'Member',
        avatarUrl: json['avatar_url'] as String? ?? '',
      );

  TeamMember copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
  }) =>
      TeamMember(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );

  static const List<TeamMember> defaultTeam = [
    TeamMember(
      id: 'u1',
      name: 'Maharab Hossain',
      email: 'maharab@taskflow.dev',
      role: 'Lead Architect',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    ),
    TeamMember(
      id: 'u2',
      name: 'Sarah Connor',
      email: 'sarah.pm@taskflow.dev',
      role: 'Product Manager',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
    TeamMember(
      id: 'u3',
      name: 'Alex River',
      email: 'alex.river@taskflow.dev',
      role: 'Senior Frontend',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    TeamMember(
      id: 'u4',
      name: 'Elena Rostova',
      email: 'elena.design@taskflow.dev',
      role: 'UI/UX Designer',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
    ),
    TeamMember(
      id: 'u5',
      name: 'David Kim',
      email: 'david.backend@taskflow.dev',
      role: 'Backend Engineer',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
    ),
  ];
}
