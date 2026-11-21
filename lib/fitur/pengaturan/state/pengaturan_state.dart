// path: lib/fitur/pengaturan/state/pengaturan_state.dart

import 'package:admin_wifi/fitur/pengaturan/model/pengaturan_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pengaturan_state.freezed.dart';

@freezed
abstract class PengaturanState with _$PengaturanState {
  const PengaturanState._();

  const factory PengaturanState({PengaturanModel? pengaturan}) =
      _PengaturanState;
}
