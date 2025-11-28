import 'package:dartz/dartz.dart';
import 'package:habit_tracker/src/core/error/failures.dart';
import 'package:habit_tracker/src/features/auth/data/repositories/user_repository.dart';
import 'package:habit_tracker/src/features/auth/data/models/user_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserUseCase {
  final UserRepository _userRepository;

  GetUserUseCase(this._userRepository);

  /// Gets a user by their ID
  Future<Either<Failure, UserModel?>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure(errors: {'id': ['User ID cannot be empty']}));
    }
    
    return await _userRepository.getUser(userId);
  }

  /// Gets a user by their email
  Future<Either<Failure, UserModel?>> getByEmail(String email) async {
    if (email.isEmpty) {
      return const Left(ValidationFailure(errors: {'email': ['Email cannot be empty']}));
    }
    
    if (!email.contains('@')) {
      return const Left(ValidationFailure(errors: {'email': ['Invalid email format']}));
    }
    
    return await _userRepository.getUserByEmail(email);
  }
}
