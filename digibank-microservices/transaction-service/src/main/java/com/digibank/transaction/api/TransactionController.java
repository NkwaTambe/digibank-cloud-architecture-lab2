package com.digibank.transaction.api;

import com.digibank.transaction.command.CreateTransactionCommand;
import com.digibank.transaction.command.TransactionCommandHandler;
import com.digibank.transaction.model.Transaction;
import com.digibank.transaction.query.TransactionQueryService;
import com.digibank.transaction.query.TransactionView;
import com.digibank.transaction.service.TransferRequest;
import com.digibank.transaction.service.TransferSagaService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/transactions")
public class TransactionController {

    private final TransactionCommandHandler commandHandler;
    private final TransactionQueryService queryService;
    private final TransferSagaService sagaService;

    public TransactionController(
            TransactionCommandHandler commandHandler,
            TransactionQueryService queryService,
            TransferSagaService sagaService) {
        this.commandHandler = commandHandler;
        this.queryService = queryService;
        this.sagaService = sagaService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Transaction create(@RequestBody CreateTransactionCommand command) {
        return commandHandler.handle(command);
    }

    @GetMapping
    public List<TransactionView> findAll() {
        return queryService.getAllViews();
    }

    @PostMapping("/transfers")
    @ResponseStatus(HttpStatus.CREATED)
    public Transaction transfer(@RequestBody TransferRequest request) {
        return sagaService.executeTransfer(request.fromAccountId(), request.toAccountId(), request.amount());
    }
}
