package com.digibank.notification.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

@Entity
@Table(name = "notifications")
@Schema(name = "Notification", description = "A business notification produced after a sensitive operation.")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Schema(description = "Unique notification identifier.", example = "1", accessMode = Schema.AccessMode.READ_ONLY)
    private Long id;

    @Column(nullable = false)
    @Schema(description = "Notification type.", example = "TRANSFER_CONFIRMED", requiredMode = Schema.RequiredMode.REQUIRED)
    private String type;

    @Column(nullable = false)
    @Schema(description = "Human readable notification message.", example = "Your transfer of 300.00 was successful.", requiredMode = Schema.RequiredMode.REQUIRED)
    private String message;

    @Column(nullable = false)
    @Schema(description = "Timestamp of when the notification was produced.", accessMode = Schema.AccessMode.READ_ONLY)
    private Instant createdAt = Instant.now();

    public Notification() {
    }

    public Notification(String type, String message) {
        this.type = type;
        this.message = message;
    }

    public Long getId() {
        return id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Instant createdAt) {
        this.createdAt = createdAt;
    }
}
