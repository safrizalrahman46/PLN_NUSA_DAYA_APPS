class ValidatorHelper {
  ValidatorHelper._();

  static String? requiredText(String? value, {String label = 'Field'}) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password wajib diisi';
    if (value.trim().length < 3) return 'Minimal 3 karakter';
    return null;
  }

  static String? numeric(String? value, {String label = 'Nilai'}) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    final parsed = double.tryParse(value.replaceAll(',', '.'));
    if (parsed == null) return '$label harus berupa angka';
    if (parsed < 0) return '$label tidak boleh minus';
    return null;
  }

  static String? cosPhi(String? value) {
    final base = numeric(value, label: 'Cos Phi');
    if (base != null) return base;
    final parsed = double.parse(value!.replaceAll(',', '.'));
    if (parsed > 1) return 'Cos Phi maksimal 1';
    return null;
  }

  static String? voltage(String? value) {
    final base = numeric(value, label: 'Tegangan');
    if (base != null) return base;
    final parsed = double.parse(value!.replaceAll(',', '.'));
    if (parsed == 0) return 'Tegangan tidak boleh 0';
    return null;
  }
}
