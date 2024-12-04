import 'package:flutter/material.dart';
import '../models/user_presence.dart';

class PresenceIndicator extends StatelessWidget {
  final UserPresence? presence;
  final double size;

  const PresenceIndicator({
    Key? key,
    required this.presence,
    this.size = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getStatusColor(),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    if (presence == null) return Colors.grey;
    
    switch (presence!.status) {
      case PresenceStatus.online:
        return Colors.green;
      case PresenceStatus.away:
        return Colors.orange;
      case PresenceStatus.busy:
        return Colors.red;
      case PresenceStatus.offline:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 