/*
Tiene la implementación del repositorio, el cual se conecta al dataSource
Nos permite a nosotros llegar a nuestro backend directamente
(Repositorio -> DataSource -> Backend)
****************************************************************
DataSource tiene las conexiones e implementaciones necesarias
*/

import 'package:articles_flutter/features/auth/infrastructure/infrastructure.dart';
import 'package:articles_flutter/features/products/infrastructure/helpers/database_helper.dart';
import 'package:articles_flutter/features/shared/infrastructure/services/key_value_storage_impl.dart';
import 'package:articles_flutter/features/shared/infrastructure/services/key_value_storage_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../domain/domain.dart';

/*
Nos permite cambiar si tengo otro de dataSource,
yo cambio el dataSource y no tengo que cambiar nada en el code
*/
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();

  return AuthNotifier(
      authRepository: authRepository,
      keyValueStorageService: keyValueStorageService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(AuthState()) {
    checkAuthStatus();
  } //no hace falta mandar nada porque todo son valores opcinonales
  //estas funciones terminan delegando en el repositorio

  Future<void> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } on CustomError catch (e) {
      logout(e.message);
    } catch (e) {
      logout('Something went wrong');
    }
    //final user = await authRepository.login(email, password);
    //state = state.copyWith(user: user, authStatus: AuthStatus.authenticated); //copia del usuario donde ya tengo el estado
  }

  //Ver si es valido el token que contiene el usuario
  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if (token == null) return logout();
    try {
      //el repositorio hace la auth
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(User user) async {
    await keyValueStorageService.setKeyValue('token', user.token);
    await DatabaseHelper.instance.initDatabase();
    state = state.copyWith(
        user: user, errorMessage: '', authStatus: AuthStatus.authenticated);
  }

  Future<void> logout([String? errorMessage]) async {
    await deleteFavoritesDatabase();
    await keyValueStorageService.removeKey('token');
    state = state.copyWith(
      user: null,
      errorMessage: errorMessage,
      authStatus: AuthStatus.notAuthenticated,
    );
  }

  Future<void> deleteFavoritesDatabase() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, "myapp.db");
    final exists = await databaseExists(path);
    if (exists) {
      await deleteDatabase(path);
    }
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState(
      {this.authStatus = AuthStatus.checking,
      this.user,
      this.errorMessage = ''});

  AuthState copyWith(
          {AuthStatus? authStatus, User? user, String? errorMessage}) =>
      AuthState(
        authStatus: authStatus ?? this.authStatus,
        user: user ?? this.user,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}
