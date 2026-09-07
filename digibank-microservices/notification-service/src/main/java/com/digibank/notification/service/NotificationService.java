package com.digibank.notification.service;

import com.digibank.notification.model.Notification;
import com.digibank.notification.repository.NotificationRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class NotificationService {

    private final NotificationRepository repository;

    public NotificationService(NotificationRepository repository) {
        this.repository = repository;
    }

    public Notification createNotification(Notification notification) {
        return repository.save(notification);
    }

    public List<Notification> getNotifications() {
        return repository.findAll();
    }
}
