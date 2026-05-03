import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../../invoice/domain/entities/invoice.dart';
import '../../../invoice/domain/entities/invoice_item.dart';
import '../../../invoice/domain/entities/invoice_status.dart';
import '../../../invoice/domain/usecases/invoice_usecases.dart';
import '../../../product/domain/entities/product.dart';
import '../../../product/domain/usecases/product_usecases.dart';
import '../../../stock/domain/entities/stock_batch.dart';
import '../../../stock/domain/usecases/stock_usecases.dart';
import '../../../../core/usecase/usecase.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final CreateDraftInvoiceUseCase createDraftInvoiceUseCase;
  final GetInvoiceUseCase getInvoiceUseCase;
  final AddOrIncrementInvoiceItemUseCase addOrIncrementInvoiceItemUseCase;
  final UpdateInvoiceItemQuantityUseCase updateInvoiceItemQuantityUseCase;
  final RemoveInvoiceItemUseCase removeInvoiceItemUseCase;
  final ConfirmInvoiceUseCase confirmInvoiceUseCase;
  final CancelDraftInvoiceUseCase cancelDraftInvoiceUseCase;
  final ListBatchesByProductUseCase listBatchesByProductUseCase;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.createDraftInvoiceUseCase,
    required this.getInvoiceUseCase,
    required this.addOrIncrementInvoiceItemUseCase,
    required this.updateInvoiceItemQuantityUseCase,
    required this.removeInvoiceItemUseCase,
    required this.confirmInvoiceUseCase,
    required this.cancelDraftInvoiceUseCase,
    required this.listBatchesByProductUseCase,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<PickSourceEvent>(_onPickSource);
    on<ClearPendingPickEvent>(_onClearPendingPick);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveProductFromCartEvent>(_onRemoveProduct);
    on<ClearCartEvent>(_onClearCart);
    on<ClearCurrentInvoiceEvent>(_onClearCurrentInvoice);
    on<OpenDraftInvoiceEvent>(_onOpenDraft);
    on<ConfirmInvoiceEvent>(_onConfirmInvoice);
    on<PrintReceiptEvent>(_onPrintReceipt);
  }

  bool _needsNewDraftInvoice() {
    final inv = state.currentInvoice;
    return inv == null || inv.status != InvoiceStatus.draft;
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    emit(state.copyWith(clearError: true, clearPendingProduct: true));

    final productResult = await getProductByBarcodeUseCase(event.barcode);
    await productResult.fold<Future<void>>(
      (failure) async {
        emit(state.copyWith(
            error: 'Không tìm thấy sản phẩm: ${event.barcode}'));
      },
      (product) async {
        final batchesResult = await listBatchesByProductUseCase(product.id);
        await batchesResult.fold<Future<void>>(
          (failure) async {
            emit(state.copyWith(error: failure.message));
          },
          (batches) async {
            final available =
                batches.where((b) => b.quantity > 0).toList();
            if (available.isEmpty) {
              emit(state.copyWith(
                  error: 'Sản phẩm ${product.name} không còn tồn kho'));
              return;
            }
            if (available.length == 1 && !available.single.isExpired) {
              await _addItem(
                emit,
                product: product,
                batch: available.single,
              );
              return;
            }
            emit(state.copyWith(
              pendingProduct: product,
              pendingSources: available,
            ));
          },
        );
      },
    );
  }

  Future<void> _onPickSource(
      PickSourceEvent event, Emitter<BillingState> emit) async {
    await _addItem(
      emit,
      product: event.product,
      batch: event.batch,
      clearPending: true,
    );
  }

  void _onClearPendingPick(
      ClearPendingPickEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(clearPendingProduct: true));
  }

  Future<void> _addItem(
    Emitter<BillingState> emit, {
    required Product product,
    required StockBatch batch,
    bool clearPending = false,
  }) async {
    late final Invoice invoice;
    if (_needsNewDraftInvoice()) {
      final draftR = await createDraftInvoiceUseCase(NoParams());
      final created = draftR.fold<Invoice?>((f) {
        emit(state.copyWith(error: f.message));
        return null;
      }, (d) => d);
      if (created == null) return;
      invoice = created;
    } else {
      invoice = state.currentInvoice!;
    }

    final item = InvoiceItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: 1,
      sourceWarehouseId: batch.warehouseId,
      sourceBatchId: batch.id,
    );

    final addR = await addOrIncrementInvoiceItemUseCase(
      AddOrIncrementInvoiceItemParams(invoiceId: invoice.id, itemDelta: item),
    );

    addR.fold(
      (f) {
        emit(state.copyWith(
          error: f.message,
          clearPendingProduct: clearPending,
        ));
      },
      (updated) {
        emit(state.copyWith(
          currentInvoice: updated,
          clearPendingProduct: clearPending,
          clearError: true,
        ));
      },
    );
  }

  Future<void> _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) async {
    final inv = state.currentInvoice;
    if (inv == null || inv.status != InvoiceStatus.draft) return;

    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId, event.sourceBatchId));
      return;
    }

    final r = await updateInvoiceItemQuantityUseCase(
      UpdateInvoiceItemQuantityParams(
        invoiceId: inv.id,
        productId: event.productId,
        sourceBatchId: event.sourceBatchId,
        quantity: event.quantity,
      ),
    );
    r.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (updated) => emit(state.copyWith(currentInvoice: updated, clearError: true)),
    );
  }

  Future<void> _onRemoveProduct(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) async {
    final inv = state.currentInvoice;
    if (inv == null || inv.status != InvoiceStatus.draft) return;

    final r = await removeInvoiceItemUseCase(
      RemoveInvoiceItemParams(
        invoiceId: inv.id,
        productId: event.productId,
        sourceBatchId: event.sourceBatchId,
      ),
    );
    await r.fold<Future<void>>(
      (f) async => emit(state.copyWith(error: f.message)),
      (updated) async {
        if (updated.items.isEmpty) {
          await cancelDraftInvoiceUseCase(inv.id);
          emit(state.clearInvoice().copyWith(clearError: true));
        } else {
          emit(state.copyWith(currentInvoice: updated, clearError: true));
        }
      },
    );
  }

  Future<void> _onClearCart(
      ClearCartEvent event, Emitter<BillingState> emit) async {
    final inv = state.currentInvoice;
    if (inv != null && inv.status == InvoiceStatus.draft) {
      await cancelDraftInvoiceUseCase(inv.id);
    }
    emit(state.clearInvoice().copyWith(clearError: true));
  }

  void _onClearCurrentInvoice(
      ClearCurrentInvoiceEvent event, Emitter<BillingState> emit) {
    emit(state.clearInvoice().copyWith(clearError: true));
  }

  Future<void> _onOpenDraft(
      OpenDraftInvoiceEvent event, Emitter<BillingState> emit) async {
    final r = await getInvoiceUseCase(event.invoiceId);
    r.fold(
      (f) => emit(state.copyWith(error: f.message)),
      (inv) {
        if (inv == null) {
          emit(state.copyWith(error: 'Không tìm thấy hóa đơn'));
          return;
        }
        if (inv.status != InvoiceStatus.draft) {
          emit(state.copyWith(error: 'Chỉ mở được đơn đang thực hiện'));
          return;
        }
        emit(state.copyWith(currentInvoice: inv, clearError: true));
      },
    );
  }

  Future<void> _onConfirmInvoice(
      ConfirmInvoiceEvent event, Emitter<BillingState> emit) async {
    final inv = state.currentInvoice;
    if (inv == null || inv.status != InvoiceStatus.draft) return;

    emit(state.copyWith(isConfirming: true, clearError: true));
    final r = await confirmInvoiceUseCase(inv.id);
    r.fold(
      (f) {
        emit(state.copyWith(
            isConfirming: false, error: f.message, clearConfirmSuccess: true));
      },
      (updated) {
        emit(state.copyWith(
          isConfirming: false,
          currentInvoice: updated,
          confirmSuccess: true,
          clearConfirmSuccess: false,
        ));
      },
    );
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final inv = state.currentInvoice;
    if (inv == null) {
      emit(state.copyWith(error: 'Không có hóa đơn để in'));
      return;
    }

    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(error: 'Không thể tự động kết nối máy in!'));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(
            error: 'Máy in chưa được kết nối và không có thiết bị đã lưu!'));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(isPrinting: true, printSuccess: false, clearError: true));

    try {
      final items = inv.items
          .map((item) => {
                'name': item.productName,
                'qty': item.quantity,
                'price': item.price,
                'total': item.lineTotal,
              })
          .toList();

      await printerHelper.printReceipt(
          shopName: event.shopName,
          address1: event.address1,
          address2: event.address2,
          phone: event.phone,
          items: items,
          total: inv.total,
          footer: event.footer);

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(isPrinting: false, error: 'In thất bại: $e'));
      emit(state.copyWith(clearError: true));
    }
  }
}
