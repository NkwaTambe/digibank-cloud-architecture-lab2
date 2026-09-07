package com.digibank.notification.service;

import com.digibank.notification.model.Notification;
import com.digibank.notification.repository.NotificationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private NotificationRepository repository;

    @InjectMocks
    private NotificationService service;

    @Test
    void recordsNotificationMessage() {
        Notification notification = new Notification("TRANSFER", "Transfer completed");
        when(repository.save(notification)).thenReturn(notification);

        Notification saved = service.createNotification(notification);

        assertThat(saved.getType()).isEqualTo("TRANSFER");
        assertThat(saved.getMessage()).isEqualTo("Transfer completed");
    }

    @Test
    void listsRecordedNotifications() {
        when(repository.findAll()).thenReturn(List.of(new Notification("COMPLIANCE", "Transaction accepted")));

        List<Notification> notifications = service.getNotifications();

        assertThat(notifications).hasSize(1);
        assertThat(notifications.get(0).getType()).isEqualTo("COMPLIANCE");
    }
}
