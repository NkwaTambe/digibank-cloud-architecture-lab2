package com.digibank.transaction.query;

import com.digibank.transaction.model.Transaction;
import com.digibank.transaction.repository.TransactionRepository;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class TransactionQueryServiceTest {

    @Test
    void returnsReadOptimizedTransactionViews() {
        TransactionRepository repository = mock(TransactionRepository.class);
        when(repository.findAll()).thenReturn(List.of(new Transaction(7L, new BigDecimal("45.00"), "DEPOSIT")));
        TransactionQueryService service = new TransactionQueryService(repository);

        List<TransactionView> views = service.getAllViews();

        assertThat(views).containsExactly(new TransactionView(null, 7L, new BigDecimal("45.00"), "DEPOSIT"));
    }
}
