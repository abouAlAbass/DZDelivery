// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$paymentsListHash() => r'e42ea2aa2001ef47fcb0e309531e613f8e2f8d26';

/// See also [paymentsList].
@ProviderFor(paymentsList)
final paymentsListProvider = AutoDisposeStreamProvider<List<Payment>>.internal(
  paymentsList,
  name: r'paymentsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$paymentsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PaymentsListRef = AutoDisposeStreamProviderRef<List<Payment>>;
String _$invoicePaymentsHash() => r'cad16bbb0224452e3afa41af0912e496da20579a';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [invoicePayments].
@ProviderFor(invoicePayments)
const invoicePaymentsProvider = InvoicePaymentsFamily();

/// See also [invoicePayments].
class InvoicePaymentsFamily extends Family<AsyncValue<List<Payment>>> {
  /// See also [invoicePayments].
  const InvoicePaymentsFamily();

  /// See also [invoicePayments].
  InvoicePaymentsProvider call(int invoiceId) {
    return InvoicePaymentsProvider(invoiceId);
  }

  @override
  InvoicePaymentsProvider getProviderOverride(
    covariant InvoicePaymentsProvider provider,
  ) {
    return call(provider.invoiceId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'invoicePaymentsProvider';
}

/// See also [invoicePayments].
class InvoicePaymentsProvider extends AutoDisposeStreamProvider<List<Payment>> {
  /// See also [invoicePayments].
  InvoicePaymentsProvider(int invoiceId)
    : this._internal(
        (ref) => invoicePayments(ref as InvoicePaymentsRef, invoiceId),
        from: invoicePaymentsProvider,
        name: r'invoicePaymentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$invoicePaymentsHash,
        dependencies: InvoicePaymentsFamily._dependencies,
        allTransitiveDependencies:
            InvoicePaymentsFamily._allTransitiveDependencies,
        invoiceId: invoiceId,
      );

  InvoicePaymentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.invoiceId,
  }) : super.internal();

  final int invoiceId;

  @override
  Override overrideWith(
    Stream<List<Payment>> Function(InvoicePaymentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: InvoicePaymentsProvider._internal(
        (ref) => create(ref as InvoicePaymentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        invoiceId: invoiceId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Payment>> createElement() {
    return _InvoicePaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is InvoicePaymentsProvider && other.invoiceId == invoiceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, invoiceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin InvoicePaymentsRef on AutoDisposeStreamProviderRef<List<Payment>> {
  /// The parameter `invoiceId` of this provider.
  int get invoiceId;
}

class _InvoicePaymentsProviderElement
    extends AutoDisposeStreamProviderElement<List<Payment>>
    with InvoicePaymentsRef {
  _InvoicePaymentsProviderElement(super.provider);

  @override
  int get invoiceId => (origin as InvoicePaymentsProvider).invoiceId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
