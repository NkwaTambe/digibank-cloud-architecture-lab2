package com.digibank.notification.api;

import com.digibank.notification.model.Notification;
import com.digibank.notification.service.NotificationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/notifications")
@Tag(name = "Notifications", description = "Endpoints for producing and listing business notifications.")
public class NotificationController {

    private final NotificationService service;

    public NotificationController(NotificationService service) {
        this.service = service;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Create a notification", description = "Creates a business notification, e.g. after a transfer.")
    public Notification create(@RequestBody Notification notification) {
        return service.createNotification(notification);
    }

    @GetMapping
    @Operation(summary = "List all notifications", description = "Returns the full list of produced notifications.")
    public List<Notification> findAll() {
        return service.getNotifications();
    }
}
