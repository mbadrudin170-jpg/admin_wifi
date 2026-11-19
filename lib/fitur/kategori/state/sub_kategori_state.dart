// path: lib/fitur/kategori/state/sub_kategori_state.dart

import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_kategori_state.freezed.dart';

@freezed
abstract class SubKategoriState with _$SubKategoriState {
  const SubKategoriState._();

  const factory SubKategoriState({
    @Default([]) List<SubKategoriModel> listSubKategori,
    @Default(0) int jumlahSubKategori,
  }) = _SubKategoriState;
}
