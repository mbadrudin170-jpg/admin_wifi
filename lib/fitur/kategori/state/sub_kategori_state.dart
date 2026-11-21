// path: lib/fitur/kategori/state/sub_kategori_state.dart

import 'package:admin_wifi/fitur/kategori/model/sub_kategori_model.dart';
import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_kategori_state.freezed.dart';

@freezed
abstract class SubKategoriState with _$SubKategoriState {
  const SubKategoriState._();

  const factory SubKategoriState({
    @Default([]) List<SubKategoriModel> listSubKategori,
    @Default(0) int jumlahSubKategori,
  }) = _SubKategoriState;

  List<SubKategoriModel> getSubKategoriByKategoriId(String idKategori) =>
      listSubKategori.where((s) => s.idKategori == idKategori).toList();

  SubKategoriModel? getSubKategoriById(String id) =>
      listSubKategori.firstWhereOrNull((s) => s.id == id);

  List<SubKategoriModel> getSubKategoriByIds(List<String> ids) =>
      listSubKategori.where((s) => ids.contains(s.id)).toList();
}
